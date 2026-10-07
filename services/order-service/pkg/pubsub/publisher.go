package pubsub

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"cloud.google.com/go/pubsub"
	"github.com/naren9876/telecom-gcp-iac/services/order-service/pkg/models"
)

type OrderPublisher struct {
	client *pubsub.Client
	topics map[string]*pubsub.Topic
}

func NewOrderPublisher(ctx context.Context, projectID string) (*OrderPublisher, error) {
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("failed to create pubsub client: %w", err)
	}

	topics := map[string]*pubsub.Topic{
		"orders.created": client.Topic("dev-orders.created"),
		"orders.updated": client.Topic("dev-orders.updated"),
	}

	for name, topic := range topics {
		exists, err := topic.Exists(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to check topic %s: %w", name, err)
		}
		if !exists {
			return nil, fmt.Errorf("topic %s does not exist", name)
		}
	}

	return &OrderPublisher{
		client: client,
		topics: topics,
	}, nil
}

func (op *OrderPublisher) PublishOrderCreated(ctx context.Context, event models.OrderEvent) (string, error) {
	return op.publishEvent(ctx, "orders.created", event)
}

func (op *OrderPublisher) PublishOrderUpdated(ctx context.Context, event models.OrderEvent) (string, error) {
	return op.publishEvent(ctx, "orders.updated", event)
}

func (op *OrderPublisher) publishEvent(ctx context.Context, topicName string, event models.OrderEvent) (string, error) {
	topic, ok := op.topics[topicName]
	if !ok {
		return "", fmt.Errorf("unknown topic: %s", topicName)
	}

	data, err := json.Marshal(event)
	if err != nil {
		return "", fmt.Errorf("failed to marshal event: %w", err)
	}

	result := topic.Publish(ctx, &pubsub.Message{
		Data: data,
		Attributes: map[string]string{
			"event_type": topicName,
			"order_id":   event.OrderID,
			"user_id":    event.UserID,
		},
	})

	messageID, err := result.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("failed to publish event: %w", err)
	}

	log.Printf("Published %s event: messageID=%s, orderID=%s", topicName, messageID, event.OrderID)
	return messageID, nil
}

func (op *OrderPublisher) Close() error {
	for _, topic := range op.topics {
		topic.Stop()
	}
	return op.client.Close()
}
