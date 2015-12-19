package main

import (
	"fmt"
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

	server := request.NewServer("http://do", "6x9=42")

	state := &comm.State{Message: ""}
	tag := &rfid.Tag{}
	for {
		select {
		case state = <-states:
			server.SendState(state)
		case tag = <-tags:
			fmt.Printf("tag: %s, %s\n", tag.CardType, tag.SerialNumber)
		}
	}
	return

}
