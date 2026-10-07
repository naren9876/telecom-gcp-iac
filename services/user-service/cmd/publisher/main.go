package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/naren9876/telecom-gcp-iac/services/user-service/pkg/pubsub"
)

func main() {
	ctx := context.Background()
	projectID := os.Getenv("GCP_PROJECT_ID")
	if projectID == "" {
		projectID = "telecom-dev-123"
	}

	publisher, err := pubsub.NewUserPublisher(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create publisher: %v", err)
	}
	defer publisher.Close()

	event := pubsub.UserEvent{
		UserID:    fmt.Sprintf("USER-%d", time.Now().Unix()),
		Email:     "newuser@example.com",
		Status:    "registered",
		Timestamp: time.Now().Unix(),
	}

	messageID, err := publisher.PublishUserRegistered(ctx, event)
	if err != nil {
		log.Fatalf("Failed to publish: %v", err)
	}

	fmt.Printf("Successfully published user registered event: %s\n", messageID)
}
