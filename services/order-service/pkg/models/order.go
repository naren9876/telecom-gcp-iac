package models

import "time"

type Order struct {
	OrderID   string
	UserID    string
	Amount    float64
	Status    string
	Timestamp int64
}

type OrderEvent struct {
	OrderID   string                 `json:"order_id"`
	UserID    string                 `json:"user_id"`
	Amount    float64                 `json:"amount"`
	Status    string                 `json:"status"`
	Timestamp int64                  `json:"timestamp"`
	Metadata  map[string]interface{} `json:"metadata,omitempty"`
}

func NewOrderEvent(order Order) OrderEvent {
	return OrderEvent{
		OrderID:   order.OrderID,
		UserID:    order.UserID,
		Amount:    order.Amount,
		Status:    order.Status,
		Timestamp: time.Now().Unix(),
	}
}
