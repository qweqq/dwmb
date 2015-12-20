package request

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"

	"dwmb/comm"
	"dwmb/rfid"
)

const (
	Free     = 0
	Occupied = 1
	Alarm    = 2
)

type Server struct {
	BaseUrl string
	Key     string
}

type stateMessage struct {
	Slots    [8]int `json:"slots"`
	Key      string `json:"key"`
	Snapshot string `json:"snapshot"`
}

type tagMessage struct {
	Hash string `json:"rfid"`
	Key  string `json:"key"`
}

type Response struct {
	Status   string `json:"status"`
	Message  string `json:"message"`
	CardCode string `json:"code"`
	Slots    [8]int `json:"slots"`
}

func NewServer(baseUrl string, Key string) *Server {
	return &Server{BaseUrl: baseUrl, Key: Key}
}

func encodeImage(filename string) (string, error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(data), nil
}

func (s *Server) SendState(state *comm.State) (*Response, error) {
	values := &stateMessage{
		Slots: state.Slots,
		Key:   s.Key,
	}
	if state.Snapshot != "" {
		snapshot, err := encodeImage(state.Snapshot)
		if err != nil {
			return nil, err
		}
		values.Snapshot = snapshot
	}
	data, err := json.Marshal(values)
	if err != nil {
		return nil, err
	}
	return s.request("alive", string(data))
}

func (s *Server) SendTag(tag *rfid.Tag) (*Response, error) {
	data, err := json.Marshal(&tagMessage{
		Hash: tag.Hash(),
		Key:  s.Key,
	})
	if err != nil {
		return nil, err
	}
	return s.request("poop", string(data))
}

func (s *Server) request(link string, data string) (*Response, error) {
	log.Printf("sending request at %s with data: %s\n", link, "")
	resp, err := http.PostForm(fmt.Sprintf("%s/%s", s.BaseUrl, link),
		url.Values{"data": {data}},
	)
	if err != nil {
		return nil, err
	}

	body, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		return nil, err
	}

	response := &Response{}
	err = json.Unmarshal(body, response)
	if err != nil {
		return nil, err
	}

	return response, nil
}
