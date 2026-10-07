package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/naren9876/telecom-gcp-iac/services/payment-service/pkg/pubsub"
)

func main() {
	ctx := context.Background()
	projectID := os.Getenv("GCP_PROJECT_ID")
	if projectID == "" {
		projectID = "telecom-dev-123"
	}

	publisher, err := pubsub.NewPaymentPublisher(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create publisher: %v", err)
	}
	defer publisher.Close()

	event := pubsub.PaymentEvent{
		OrderID:   "ORD-1791338556",
		PaymentID: fmt.Sprintf("PAY-%d", time.Now().Unix()),
		Amount:    99.99,
		Status:    "completed",
		Timestamp: time.Now().Unix(),
	}

	messageID, err := publisher.PublishPaymentProcessed(ctx, event)
	if err != nil {
		log.Fatalf("Failed to publish: %v", err)
	}

	fmt.Printf("Successfully published payment processed event: %s\n", messageID)
}
