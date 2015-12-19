package main

import (
	"log"

	"dwmb/comm"
	"dwmb/request"
	"dwmb/rfid"
)

func quickMessage(messages chan<- *comm.DisplayMessage, text string) {
	messages <- &comm.DisplayMessage{Message: text}
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

	messages <- &comm.DisplayMessage{Message: "foo\nbar"}

	for {
		select {
		case state = <-states:
			resp, err := server.SendState(state)
			if err != nil {
				log.Print(err)
			} else {
				log.Printf("got response: %v\n", resp)
			}
		case tag = <-tags:
			resp, err := server.SendTag(tag)
			if err != nil {
				quickMessage(messages, "error :(")
				log.Print(err)
			} else {
				log.Printf("got response: %v\n", resp)
			}
		}
	}
	return

}
