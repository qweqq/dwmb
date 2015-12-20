package sound

import (
	"os/exec"
	"sync"
)

type Sound struct {
	SoundsFolder string
	currentSound string
	player       *exec.Cmd
	mutex        *sync.Mutex
}

func NewSound(soundsFolder string) *Sound {
	return &Sound{
		SoundsFolder: soundsFolder,
		currentSound: "",
		mutex:        &sync.Mutex{},
	}
}

func (s *Sound) Play(sound string, override bool) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	if s.currentSound == sound {
		return
	}

	s.currentSound = sound

	if s.player != nil {
		if override {
			s.Stop()
		} else {
			return
		}
	}
	soundFile := s.SoundsFolder + "/" + sound + ".ogg"
	s.player = exec.Command("play", soundFile)
	go func(s *Sound) {
		s.player.Run()
		s.player = nil
		s.currentSound = ""
	}(s)
}

func (s *Sound) Stop() {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	if s.player != nil {
		s.player.Process.Kill()
		s.player = nil
	}
}
