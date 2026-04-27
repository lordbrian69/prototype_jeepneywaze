package mqtt

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	pahomqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/jeepneywaze/gps-ingestion/models"
)

// Subscriber listens to MQTT topic jw/gps/# and forwards pings
// to the provided channel for Kafka publishing.
type Subscriber struct {
	client   pahomqtt.Client
	pingChan chan<- *models.GPSPing
}

func NewSubscriber(pingChan chan<- *models.GPSPing) (*Subscriber, error) {
	brokerURL := os.Getenv("MQTT_BROKER_URL")
	if brokerURL == "" {
		brokerURL = "tcp://localhost:1883"
	}

	opts := pahomqtt.NewClientOptions().
		AddBroker(brokerURL).
		SetClientID("jw-gps-ingestion").
		SetKeepAlive(30 * time.Second).
		SetPingTimeout(10 * time.Second).
		SetCleanSession(true).
		SetAutoReconnect(true).
		SetOnConnectHandler(func(c pahomqtt.Client) {
			log.Println("MQTT connected, subscribing to jw/gps/#")
			// Subscribe to all GPS topics: jw/gps/{user_token}
			if tok := c.Subscribe("jw/gps/#", 1, nil); tok.Wait() && tok.Error() != nil {
				log.Printf("MQTT subscribe error: %v", tok.Error())
			}
		}).
		SetConnectionLostHandler(func(_ pahomqtt.Client, err error) {
			log.Printf("MQTT connection lost: %v", err)
		})

	client := pahomqtt.NewClient(opts)
	if tok := client.Connect(); tok.Wait() && tok.Error() != nil {
		return nil, fmt.Errorf("MQTT connect: %w", tok.Error())
	}

	s := &Subscriber{client: client, pingChan: pingChan}

	// Set default message handler after connection
	client.AddRoute("jw/gps/#", s.handleMessage)

	return s, nil
}

func (s *Subscriber) handleMessage(_ pahomqtt.Client, msg pahomqtt.Message) {
	var ping models.GPSPing
	if err := json.Unmarshal(msg.Payload(), &ping); err != nil {
		log.Printf("Invalid GPS ping payload: %v", err)
		return
	}

	if ping.Ts.IsZero() {
		ping.Ts = time.Now().UTC()
	}

	// Non-blocking send — drop if channel full (back-pressure)
	select {
	case s.pingChan <- &ping:
	default:
		log.Printf("GPS ping channel full, dropping ping from %s", ping.UserToken)
	}
}

func (s *Subscriber) Run(ctx context.Context) {
	<-ctx.Done()
	s.client.Disconnect(500)
}
