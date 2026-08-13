package engine

import (
	"encoding/json"
	"io"
	"sync"
)

// JSONLineWriter writes JSON-encoded events as newline-delimited lines.
type JSONLineWriter struct {
	w  io.Writer
	mu sync.Mutex
}

// NewJSONLineWriter creates a writer that emits JSON lines to w.
func NewJSONLineWriter(w io.Writer) *JSONLineWriter {
	return &JSONLineWriter{w: w}
}

// WriteEvent writes a StatusEvent as a JSON line.
func (j *JSONLineWriter) WriteEvent(e StatusEvent) error {
	j.mu.Lock()
	defer j.mu.Unlock()
	data, err := json.Marshal(e)
	if err != nil {
		return err
	}
	data = append(data, '\n')
	_, err = j.w.Write(data)
	return err
}

// WriteProgress writes a ProgressEvent as a JSON line.
func (j *JSONLineWriter) WriteProgress(e ProgressEvent) error {
	j.mu.Lock()
	defer j.mu.Unlock()
	data, err := json.Marshal(e)
	if err != nil {
		return err
	}
	data = append(data, '\n')
	_, err = j.w.Write(data)
	return err
}

// countingReader wraps an io.Reader and reports bytes read via a callback.
type countingReader struct {
	r        io.Reader
	total    int64
	read     int64
	callback func(sent, total int64)
}

// newCountingReader wraps r and calls cb after each Read with (bytesRead, totalBytes).
// If total is 0, percent calculations should be skipped by the callback.
func newCountingReader(r io.Reader, total int64, cb func(sent, total int64)) *countingReader {
	return &countingReader{r: r, total: total, callback: cb}
}

func (cr *countingReader) Read(p []byte) (int, error) {
	n, err := cr.r.Read(p)
	cr.read += int64(n)
	if cr.callback != nil && n > 0 {
		cr.callback(cr.read, cr.total)
	}
	return n, err
}
