package pubsub

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"cloud.google.com/go/pubsub"
)

type UserEvent struct {
	UserID    string `json:"user_id"`
	Email     string `json:"email"`
	Status    string `json:"status"`
	Timestamp int64  `json:"timestamp"`
}

type UserPublisher struct {
	client *pubsub.Client
	topic  *pubsub.Topic
}

func NewUserPublisher(ctx context.Context, projectID string) (*UserPublisher, error) {
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("failed to create pubsub client: %w", err)
	}

	topic := client.Topic("dev-users.registered")
	exists, err := topic.Exists(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to check topic: %w", err)
	}
	if !exists {
		return nil, fmt.Errorf("topic dev-users.registered does not exist")
	}

	return &UserPublisher{
		client: client,
		topic:  topic,
	}, nil
}

func (up *UserPublisher) PublishUserRegistered(ctx context.Context, event UserEvent) (string, error) {
	data, err := json.Marshal(event)
	if err != nil {
		return "", fmt.Errorf("failed to marshal event: %w", err)
	}

	result := up.topic.Publish(ctx, &pubsub.Message{
		Data: data,
		Attributes: map[string]string{
			"event_type": "users.registered",
			"user_id":    event.UserID,
			"email":      event.Email,
		},
	})

	messageID, err := result.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("failed to publish event: %w", err)
	}

	log.Printf("Published users.registered event: messageID=%s, userID=%s", messageID, event.UserID)
	return messageID, nil
}

func (up *UserPublisher) Close() error {
	up.topic.Stop()
	return up.client.Close()
}
