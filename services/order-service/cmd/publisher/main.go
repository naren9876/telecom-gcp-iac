package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/naren9876/telecom-gcp-iac/services/order-service/pkg/models"
	"github.com/naren9876/telecom-gcp-iac/services/order-service/pkg/pubsub"
)

func main() {
	ctx := context.Background()
	projectID := os.Getenv("GCP_PROJECT_ID")
	if projectID == "" {
		projectID = "telecom-dev-123"
	}

	publisher, err := pubsub.NewOrderPublisher(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create publisher: %v", err)
	}
	defer publisher.Close()

	order1 := models.Order{
		OrderID:   fmt.Sprintf("ORD-%d", time.Now().Unix()),
		UserID:    "USER-001",
		Amount:    99.99,
		Status:    "created",
		Timestamp: time.Now().Unix(),
	}

	event1 := models.NewOrderEvent(order1)
	event1.Metadata = map[string]interface{}{
		"currency": "USD",
		"region":   "US-EAST",
	}

	messageID, err := publisher.PublishOrderCreated(ctx, event1)
	if err != nil {
		log.Fatalf("Failed to publish order created: %v", err)
	}
	fmt.Printf("Successfully published order created event: %s\n", messageID)

	time.Sleep(1 * time.Second)

	order2 := models.Order{
		OrderID:   order1.OrderID,
		UserID:    order1.UserID,
		Amount:    order1.Amount,
		Status:    "processing",
		Timestamp: time.Now().Unix(),
	}

	event2 := models.NewOrderEvent(order2)
	messageID2, err := publisher.PublishOrderUpdated(ctx, event2)
	if err != nil {
		log.Fatalf("Failed to publish order updated: %v", err)
	}
	fmt.Printf("Successfully published order updated event: %s\n", messageID2)
}
