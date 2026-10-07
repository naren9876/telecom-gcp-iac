package pubsub

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"cloud.google.com/go/pubsub"
)

type PaymentEvent struct {
	OrderID   string  `json:"order_id"`
	PaymentID string  `json:"payment_id"`
	Amount    float64 `json:"amount"`
	Status    string  `json:"status"`
	Timestamp int64   `json:"timestamp"`
}

type UserEvent struct {
	UserID    string `json:"user_id"`
	Email     string `json:"email"`
	Status    string `json:"status"`
	Timestamp int64  `json:"timestamp"`
}

type OrderSubscriber struct {
	client        *pubsub.Client
	subscriptions map[string]*pubsub.Subscription
	mu            sync.RWMutex
	done          chan struct{}
}

func NewOrderSubscriber(ctx context.Context, projectID string) (*OrderSubscriber, error) {
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("failed to create pubsub client: %w", err)
	}

	subscriptions := map[string]*pubsub.Subscription{
		"payments.processed": client.Subscription("dev-payments_processed_order_service"),
		"users.registered":   client.Subscription("dev-users_registered_order_service"),
	}

	for name, sub := range subscriptions {
		exists, err := sub.Exists(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to check subscription %s: %w", name, err)
		}
		if !exists {
			return nil, fmt.Errorf("subscription %s does not exist", name)
		}
	}

	return &OrderSubscriber{
		client:        client,
		subscriptions: subscriptions,
		done:          make(chan struct{}),
	}, nil
}

func (os *OrderSubscriber) Start(ctx context.Context) error {
	for eventType, sub := range os.subscriptions {
		go os.receiveMessages(ctx, eventType, sub)
	}
	log.Println("Order Service subscriber started. Listening for events...")
	return nil
}

func (os *OrderSubscriber) receiveMessages(ctx context.Context, eventType string, sub *pubsub.Subscription) {
	for {
		select {
		case <-os.done:
			return
		default:
		}

		cctx, cancel := context.WithTimeout(ctx, 30*time.Second)
		err := sub.Receive(cctx, func(ctx context.Context, msg *pubsub.Message) {
			switch eventType {
			case "payments.processed":
				os.handlePaymentProcessed(msg)
			case "users.registered":
				os.handleUserRegistered(msg)
			}
		})
		cancel()

		if err != nil && err != context.Canceled {
			log.Printf("Error receiving messages for %s: %v", eventType, err)
		}
	}
}

func (os *OrderSubscriber) handlePaymentProcessed(msg *pubsub.Message) {
	var event PaymentEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal payment event: %v", err)
		msg.Nack()
		return
	}

	log.Printf("[PAYMENT] Order Service received payment processed: orderID=%s, status=%s, amount=%.2f", event.OrderID, event.Status, event.Amount)

	if event.Status == "completed" {
		log.Printf("[FULFILLMENT] Triggering fulfillment for order %s", event.OrderID)
	}

	msg.Ack()
}

func (os *OrderSubscriber) handleUserRegistered(msg *pubsub.Message) {
	var event UserEvent
	if err := json.Unmarshal(msg.Data, &event); err != nil {
		log.Printf("Failed to unmarshal user event: %v", err)
		msg.Nack()
		return
	}

	log.Printf("[USER] Order Service received user registered: userID=%s, email=%s", event.UserID, event.Email)
	log.Printf("[WELCOME] Creating welcome order for new user %s", event.UserID)

	msg.Ack()
}

func (os *OrderSubscriber) Stop() error {
	close(os.done)
	time.Sleep(1 * time.Second)
	return os.client.Close()
}
