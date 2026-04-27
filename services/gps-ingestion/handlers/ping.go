package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jeepneywaze/gps-ingestion/models"
)

// NewPingHandler returns a Gin handler that accepts HTTP POST GPS pings.
// This is the fallback for clients that cannot use MQTT
// (e.g. poor connectivity, battery-save mode bulk upload).
func NewPingHandler(pingChan chan<- *models.GPSPing) gin.HandlerFunc {
	return func(c *gin.Context) {
		var ping models.GPSPing
		if err := c.ShouldBindJSON(&ping); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if ping.Ts.IsZero() {
			ping.Ts = time.Now().UTC()
		}

		select {
		case pingChan <- &ping:
			c.JSON(http.StatusAccepted, gin.H{"ok": true})
		default:
			c.JSON(http.StatusTooManyRequests, gin.H{"error": "server busy, retry"})
		}
	}
}

func Health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"service": "jw-gps-ingestion",
		"status":  "ok",
		"ts":      time.Now().UTC(),
	})
}
