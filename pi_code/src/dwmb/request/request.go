package request

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"

	"dwmb/comm"
)

type Server struct {
	BaseUrl string
	Key     string
}

type stateMessage struct {
	Slots [8]int `json:"slots"`
	Key   string `json:"key"`
}

func NewServer(baseUrl string, Key string) *Server {
	return &Server{BaseUrl: baseUrl, Key: Key}
}

func (s *Server) SendState(state *comm.State) error {
	data, err := json.Marshal(&stateMessage{
		Slots: state.Slots,
		Key:   s.Key,
	})
	if err != nil {
		return err
	}
	resp, err := s.request("alive", string(data))
	if err != nil {
		return err
	}
	fmt.Printf("resp: %s\n", string(resp))
	return nil
}

func (s *Server) request(link string, data string) ([]byte, error) {
	resp, err := http.PostForm(fmt.Sprintf("%s/%s", s.BaseUrl, link),
		url.Values{"data": {data}},
	)
	if err != nil {
		return make([]byte, 0), err
	}
	body, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		return make([]byte, 0), err
	}
	return body, nil
}
