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

const (
	Off    = 0
	Red    = 1
	Green  = 2
	Yellow = 3
)

type State struct {
	Slots   [8]int
	Message string
}

type DisplayMessage struct {
	Message string
	Lights  [8]int
}

func Init(device string, baud int) (chan *State, chan *DisplayMessage, error) {
	stateMessages := make(chan *State)
	displayMessages := make(chan *DisplayMessage)

	f, err := serial.OpenPort(&serial.Config{Name: device, Baud: baud})
	if err != nil {
		return stateMessages, displayMessages, err
	}

	go receive(f, stateMessages)
	go send(f, displayMessages)

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

func send(f *serial.Port, displayMessages <-chan *DisplayMessage) {
	for {
		message := <-displayMessages
		if message.Message != "" {
			if message.Message == "\a" {
				f.Write([]byte("o\n"))
			} else {
				f.Write([]byte("d" + strings.Replace(message.Message, "\n", "\v", -1) + "\n"))
			}
		}
		ledMessage := make([]byte, 8+2)
		ledMessage[0] = 'l'
		for i, lamp := range message.Lights {
			switch lamp {
			case Red:
				ledMessage[i+1] = 'r'
			case Green:
				ledMessage[i+1] = 'g'
			case Yellow:
				ledMessage[i+1] = 'y'
			default:
				ledMessage[i+1] = 'o'
			}
		}
		ledMessage[9] = '\n'
		f.Write(ledMessage)
	}
}
