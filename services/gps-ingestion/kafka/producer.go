package kafka

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/jeepneywaze/gps-ingestion/models"
	segkafka "github.com/segmentio/kafka-go"
)

type Producer struct {
	writer *segkafka.Writer
	topic  string
}

func NewProducer() (*Producer, error) {
	brokers := strings.Split(os.Getenv("KAFKA_BROKERS"), ",")
	topic := os.Getenv("KAFKA_TOPIC_GPS_PINGS")
	if topic == "" {
		topic = "gps.pings"
	}

	w := &segkafka.Writer{
		Addr:                   segkafka.TCP(brokers...),
		Topic:                  topic,
		Balancer:               &segkafka.LeastBytes{},
		AllowAutoTopicCreation: true,
		BatchSize:              100,      // Batch up to 100 pings per write
		BatchTimeout:           5e6,      // 5ms batch window
		RequiredAcks:           segkafka.RequireOne,
	}

	return &Producer{writer: w, topic: topic}, nil
}

// Publish sends a GPS ping to Kafka.
// The user_token is used as the partition key so all pings
// from the same user land on the same partition (ordered trajectory).
func (p *Producer) Publish(ctx context.Context, ping *models.GPSPing) error {
	payload, err := json.Marshal(ping)
	if err != nil {
		return fmt.Errorf("marshal ping: %w", err)
	}

	return p.writer.WriteMessages(ctx, segkafka.Message{
		Key:   []byte(ping.UserToken),
		Value: payload,
	})
}

func (p *Producer) Close() error {
	return p.writer.Close()
}
