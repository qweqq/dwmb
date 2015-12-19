package main

import (
	"fmt"
	"log"

	"dwmb/comm"
)

func main() {
	states, _, err := comm.Init("/dev/ttyAMA0", 115200)
	if err != nil {
		log.Fatal(err)
	}

	state := &comm.State{Message: ""}
	for {
		state = <-states
		fmt.Printf("state: %v %s\n", state.Slots, state.Message)
	}
	return
	/*
		resp, err := http.Get("https://archlinux.org")
		if err != nil {
			log.Fatal(err)
		}
		body, err := ioutil.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("resp: %s\n", body)
	*/
}
