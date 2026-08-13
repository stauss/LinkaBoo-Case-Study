package engine

// EventType identifies the kind of JSON line event emitted by the CLI.
type EventType string

const (
	EventCode     EventType = "code"
	EventProgress EventType = "progress"
	EventComplete EventType = "complete"
	EventError    EventType = "error"
)

// StatusEvent is emitted for code, complete, and error events.
type StatusEvent struct {
	Type      EventType `json:"type"`
	Code      string    `json:"code,omitempty"`
	Link      string    `json:"link,omitempty"`
	Message   string    `json:"message,omitempty"`
	FileName  string    `json:"file_name,omitempty"`
	FileCount int       `json:"file_count,omitempty"`
	OK        bool      `json:"ok,omitempty"`
}

// ProgressEvent is emitted periodically during a transfer.
type ProgressEvent struct {
	Type       EventType `json:"type"`
	SentBytes  int64     `json:"sent_bytes"`
	TotalBytes int64     `json:"total_bytes"`
	Percent    float64   `json:"percent"`
}

// ReceiveResult is returned by Receive after a successful transfer.
type ReceiveResult struct {
	Name          string
	Type          string
	BytesReceived int64
	FileCount     int
}
