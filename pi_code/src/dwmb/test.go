package main

import (
	"log"
	"time"

	"dwmb/comm"
	"dwmb/display"
	"dwmb/request"
	"dwmb/rfid"
	"dwmb/sound"
)

func quickMessage(messages chan<- *comm.DisplayMessage, text string) {
	messages <- &comm.DisplayMessage{Message: text}
}

func processResponse(messages chan<- *comm.DisplayMessage, messageTimer *time.Timer, resp *request.Response) {
	log.Printf("got response: %v\n", resp)

	message := &comm.DisplayMessage{}

	if resp.Message != "" && resp.Message != "ok" {
		text, timeout := display.MakeMessage(resp)
		messageTimer.Reset(timeout * time.Second)
		message.Message = text
	}

	for i, slot := range resp.Slots {
		switch slot {
		case request.Free:
			message.Lights[i] = comm.Green
		case request.Occupied:
			message.Lights[i] = comm.Yellow
		case request.Alarm:
			message.Lights[i] = comm.Red
		default:
			message.Lights[i] = comm.Off
		}
	}
	messages <- message
	return
}

func main() {
	states, messages, err := comm.Init("/dev/ttyAMA0", 115200)
	if err != nil {
		log.Fatal(err)
	}

	tags, err := rfid.Init("/tmp/poop")
	if err != nil {
		log.Fatal(err)
	}

	server := request.NewServer("http://do:1234", "6x9=42")

	state := &comm.State{Message: ""}
	tag := &rfid.Tag{}

	sound := sound.NewSound("./sounds")

	messages <- &comm.DisplayMessage{Message: "hi!"}

	messageTimer := time.NewTimer(3 * time.Second)
	go func() {
		for {
			<-messageTimer.C
			messages <- &comm.DisplayMessage{Message: "\a"}
		}
	}()

	for {
		select {
		case state = <-states:
			state.Snapshot = "/tmp/cam1/lastsnap.jpg"
			resp, err := server.SendState(state)
			if err != nil {
				log.Print(err)
			} else {
				if resp.Message == "theft" {
					sound.Play("alarm", true)
				} else {
					sound.Stop()
				}
				processResponse(messages, messageTimer, resp)
			}
		case tag = <-tags:
			resp, err := server.SendTag(tag)
			if err != nil {
				quickMessage(messages, "error :(")
				log.Print(err)
			} else {
				sound.Play("poop", false)
				processResponse(messages, messageTimer, resp)
			}
		}
	}
}
