package rfid

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
)

type Tag struct {
	CardType     string
	SerialNumber string
}

func makeTag(text string) (*Tag, error) {
	data := strings.TrimSpace(text)
	portions := strings.Split(data, " ")
	if len(portions) != 3 && portions[0] != "tag" {
		return nil, fmt.Errorf("Wrong tag: %s", data)
	}
	return &Tag{CardType: portions[1], SerialNumber: portions[2]}, nil
}

func Init(rfid_pipe string) (chan *Tag, error) {
	tags := make(chan *Tag)

	f, err := os.Open(rfid_pipe)
	if err != nil {
		return tags, err
	}
	go read(f, tags)
	return tags, nil
}

func read(f *os.File, tags chan *Tag) {
	buf := bufio.NewScanner(f)
	for buf.Scan() {
		tag, err := makeTag(buf.Text())
		if err != nil {
			log.Print(err)
		} else {
			tags <- tag
		}
	}
}
