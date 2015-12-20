package sound

import (
	"log"
	"os/exec"
)

type Sound struct {
	SoundsFolder string
	currentSound string
	player       *exec.Cmd
}

func NewSound(soundsFolder string) *Sound {
	return &Sound{
		SoundsFolder: soundsFolder,
		currentSound: "",
	}
}

func (s *Sound) Play(sound string, override bool) {
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
	log.Printf("playing sound: %s\n", soundFile)
	s.player = exec.Command("play", soundFile)
	s.player.Start()
}

func (s *Sound) Stop() {
	if s.player != nil {
		s.player.Process.Kill()
		s.player = nil
	}
}
