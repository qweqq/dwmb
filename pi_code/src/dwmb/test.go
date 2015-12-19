package main

import (
	"log"

	"dwmb/comm"
	"dwmb/request"
	"dwmb/rfid"
)

func main() {
	states, _, err := comm.Init("/dev/ttyAMA0", 115200)
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
	for {
		select {
		case state = <-states:
			err := server.SendState(state)
			if err != nil {
				log.Print(err)
			}
		case tag = <-tags:
			err := server.SendTag(tag)
			if err != nil {
				log.Print(err)
			}
		}
	}
	return

}
