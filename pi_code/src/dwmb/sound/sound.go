package sound

import "os/exec"

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

func (s *Sound) Play(sound string) {
	if s.currentSound == sound {
		return
	}
	if s.player != nil {
		s.player.Process.Kill()
	}
	s.player = exec.Command("play", s.SoundsFolder+"/"+sound+".ogg")
	s.player.Start()
}
