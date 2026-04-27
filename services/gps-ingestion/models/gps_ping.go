package models

import "time"

// GPSPing is a single location report from a commuter or driver app.
// Published to MQTT topic: jw/gps/{user_token}
// Forwarded to Kafka topic: gps.pings
type GPSPing struct {
	UserToken  string    `json:"user_token" binding:"required"`
	Lat        float64   `json:"lat" binding:"required,min=-90,max=90"`
	Lng        float64   `json:"lng" binding:"required,min=-180,max=180"`
	AccuracyM  float64   `json:"accuracy_m"`
	SpeedKmh   float64   `json:"speed_kmh"`
	HeadingDeg float64   `json:"heading_deg"`
	AltitudeM  float64   `json:"altitude_m"`
	IsMoving   bool      `json:"is_moving"`
	Ts         time.Time `json:"ts"`
	Source     string    `json:"source"` // "commuter" | "driver"
}
