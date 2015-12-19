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
	Slots   [8]int
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
	state := &State{Message: data}
	if data[0] == 's' {
		for i := 1; i < len(data); i++ {
			switch data[i] {
			case 'p':
				state.Slots[i-1] = Plugged
			case 'u':
				state.Slots[i-1] = Unplugged
			}
		}
	}
	return state
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

		portions := strings.Split(data, "\n")
		for _, portion := range portions[:len(portions)-1] {
			if len(portion) > 0 {
				if portion[0] == 's' {
					stateMessages <- makeState(portion)
				}
			}
		}
		data = portions[len(portions)-1]
	}
}
