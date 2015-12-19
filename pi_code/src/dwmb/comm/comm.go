package comm

import (
	"log"
	"strings"

	"github.com/tarm/serial"
)

const (
	Unplugged = 0
	Plugged   = 1
)

type State struct {
	States  [8]int
	Message string
}

type DisplayMessage struct {
	Message string
}

func Init(device string, baud int) (chan *State, chan *DisplayMessage, error) {
	stateMessages := make(chan *State)
	displayMessages := make(chan *DisplayMessage)

	f, err := serial.OpenPort(&serial.Config{Name: device, Baud: baud})
	if err != nil {
		return stateMessages, displayMessages, err
	}
	go receive(f, stateMessages)
	return stateMessages, displayMessages, nil
}

func makeState(data string) *State {
	return &State{Message: data}
}

func receive(f *serial.Port, stateMessages chan<- *State) {
	buf := make([]byte, 128)
	var (
		err  error
		n    int
		data string
	)

	for {
		n, err = f.Read(buf)
		if err != nil {
			log.Print(err)
		}
		data += string(buf[:n])

		if data[len(data)-1] == '\n' {
			stateMessages <- makeState(strings.TrimSpace(data))
			data = ""
		}
	}
}
