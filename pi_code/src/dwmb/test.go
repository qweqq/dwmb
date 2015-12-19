package main

import (
	"log"

	"dwmb/comm"
	"dwmb/request"
)

func main() {
	states, _, err := comm.Init("/dev/ttyAMA0", 115200)
	if err != nil {
		log.Fatal(err)
	}

	server := request.NewServer("http://do", "6x9=42")

	state := &comm.State{Message: ""}
	for {
		select {
		case state = <-states:
			server.SendState(state)
		}
	}
	return

}
