package pubsub

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"cloud.google.com/go/pubsub"
)

type PaymentEvent struct {
	OrderID   string  `json:"order_id"`
	PaymentID string  `json:"payment_id"`
	Amount    float64 `json:"amount"`
	Status    string  `json:"status"`
	Timestamp int64   `json:"timestamp"`
}

type PaymentPublisher struct {
	client *pubsub.Client
	topic  *pubsub.Topic
}

func NewPaymentPublisher(ctx context.Context, projectID string) (*PaymentPublisher, error) {
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("failed to create pubsub client: %w", err)
	}

	topic := client.Topic("dev-payments.processed")
	exists, err := topic.Exists(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to check topic: %w", err)
	}
	if !exists {
		return nil, fmt.Errorf("topic dev-payments.processed does not exist")
	}

	return &PaymentPublisher{
		client: client,
		topic:  topic,
	}, nil
}

func (pp *PaymentPublisher) PublishPaymentProcessed(ctx context.Context, event PaymentEvent) (string, error) {
	data, err := json.Marshal(event)
	if err != nil {
		return "", fmt.Errorf("failed to marshal event: %w", err)
	}

	result := pp.topic.Publish(ctx, &pubsub.Message{
		Data: data,
		Attributes: map[string]string{
			"event_type": "payments.processed",
			"order_id":   event.OrderID,
			"payment_id": event.PaymentID,
		},
	})

	messageID, err := result.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("failed to publish event: %w", err)
	}

	log.Printf("Published payments.processed event: messageID=%s, orderID=%s", messageID, event.OrderID)
	return messageID, nil
}

func (pp *PaymentPublisher) Close() error {
	pp.topic.Stop()
	return pp.client.Close()
}
