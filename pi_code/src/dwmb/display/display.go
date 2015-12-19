package display

import (
	"fmt"
	"log"
	"time"

	"dwmb/request"
)

func MakeMessage(resp *request.Response) (string, time.Duration) {
	messageId := resp.Message
	log.Printf("message: %s\n", messageId)
	switch messageId {
	case "connecting":
		if resp.CardCode != "" {
			return fmt.Sprintf("Attach bike.\nRegister: %s", resp.CardCode), 30
		}
		return "Please attach\nyour bike :)", 30
	case "theft":
		return "RUN !", 15
	case "connected":
		return "Bike attached", 6
	case "cable":
		return "Don't touch me!", 6
	case "disconnecting":
		return "You can detach\nyour bike!", 30
	case "disconnected":
		return "Goodbye ^-^", 6
	default:
		return "Unknown message", 6
	}
}
