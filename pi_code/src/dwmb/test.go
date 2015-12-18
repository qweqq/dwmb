package main

import (
	"io/ioutil"
	"log"
	"net/http"

	"github.com/tarm/serial"
)

func main() {
	s, err := serial.OpenPort(&serial.Config{Name: "/dev/ttyAMA0", Baud: 115200})
	if err != nil {
		log.Fatal(err)
	}

	n, err := s.Write([]byte("c"))
	if err != nil {
		log.Fatal(err)
	}

	buf := make([]byte, 128)
	n, err = s.Read(buf)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("%q", buf[:n])

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
}
