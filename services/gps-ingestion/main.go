package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jeepneywaze/gps-ingestion/handlers"
	"github.com/jeepneywaze/gps-ingestion/kafka"
	"github.com/jeepneywaze/gps-ingestion/models"
	"github.com/jeepneywaze/gps-ingestion/mqtt"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load("../../.env")

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	// ── Kafka producer ────────────────────────────────────
	producer, err := kafka.NewProducer()
	if err != nil {
		log.Fatalf("Kafka producer init: %v", err)
	}
	defer producer.Close()

	// ── Ping channel (MQTT → Kafka) ───────────────────────
	// Buffer of 10,000 pings — handles burst traffic during peak hours
	pingChan := make(chan *models.GPSPing, 10_000)

	// ── MQTT subscriber ───────────────────────────────────
	mqttSub, err := mqtt.NewSubscriber(pingChan)
	if err != nil {
		log.Fatalf("MQTT subscriber init: %v", err)
	}
	go mqttSub.Run(ctx)

	// ── Kafka publish workers (fanout) ────────────────────
	for i := 0; i < 4; i++ {
		go func() {
			for {
				select {
				case ping := <-pingChan:
					pubCtx, pubCancel := context.WithTimeout(ctx, 5*time.Second)
					if err := producer.Publish(pubCtx, ping); err != nil {
						log.Printf("Kafka publish error: %v", err)
					}
					pubCancel()
				case <-ctx.Done():
					return
				}
			}
		}()
	}

	// ── HTTP server (health + direct HTTP POST fallback) ──
	port := os.Getenv("INGESTION_PORT")
	if port == "" {
		port = "8080"
	}

	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())
	r.GET("/health", handlers.Health)
	r.POST("/ping", handlers.NewPingHandler(pingChan))

	srv := &http.Server{Addr: ":" + port, Handler: r}
	go func() {
		log.Printf("GPS ingestion service on :%s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("HTTP server: %v", err)
		}
	}()

	<-ctx.Done()
	log.Println("Shutting down GPS ingestion...")
	shutCtx, shutCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutCancel()
	_ = srv.Shutdown(shutCtx)
}
