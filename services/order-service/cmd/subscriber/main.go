package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/naren9876/telecom-gcp-iac/services/order-service/pkg/pubsub"
)

func main() {
	ctx := context.Background()
	projectID := os.Getenv("GCP_PROJECT_ID")
	if projectID == "" {
		projectID = "telecom-dev-123"
	}

	subscriber, err := pubsub.NewOrderSubscriber(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create subscriber: %v", err)
	}

	if err := subscriber.Start(ctx); err != nil {
		log.Fatalf("Failed to start subscriber: %v", err)
	}

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	<-sigChan
	log.Println("Shutting down subscriber...")

	if err := subscriber.Stop(); err != nil {
		log.Printf("Error stopping subscriber: %v", err)
	}

	log.Println("Subscriber stopped gracefully")
}
