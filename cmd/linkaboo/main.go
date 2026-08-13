package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"regexp"
	"strings"
	"syscall"

	wh "github.com/psanford/wormhole-william/wormhole"
	"github.com/stauss/LinkaBoo-Case-Study/internal/engine"
)

const version = "0.1.0"

var codePattern = regexp.MustCompile(`^\d+-\w+-\w+$`)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "send":
		cmdSend(os.Args[2:])
	case "receive":
		cmdReceive(os.Args[2:])
	case "version":
		fmt.Printf("linkaboo %s\n", version)
	default:
		fmt.Fprintf(os.Stderr, "unknown command: %s\n", os.Args[1])
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Fprintln(os.Stderr, `Usage: linkaboo <command> [options]

Commands:
  send <path> [--json]              Send a file or directory
  receive <code> [--dest dir] [--json]  Receive a transfer
  version                           Print version`)
}

func cmdSend(args []string) {
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "Usage: linkaboo send <path> [--json]")
		os.Exit(1)
	}

	path := args[0]
	jsonMode := hasFlag(args[1:], "--json")

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	jw := engine.NewJSONLineWriter(os.Stdout)
	cfg, client, err := loadClient()
	if err != nil {
		exitWithError(jsonMode, jw, err)
	}

	progressFn := func(sent, total int64) {
		if jsonMode {
			var pct float64
			if total > 0 {
				pct = float64(sent) / float64(total) * 100
			}
			jw.WriteProgress(engine.ProgressEvent{
				Type:       engine.EventProgress,
				SentBytes:  sent,
				TotalBytes: total,
				Percent:    pct,
			})
		}
	}

	code, resultCh, err := engine.Send(ctx, client, path, progressFn)
	if err != nil {
		exitWithError(jsonMode, jw, err)
	}

	if jsonMode {
		jw.WriteEvent(engine.StatusEvent{Type: engine.EventCode, Code: code, Link: cfg.ShareLink(code)})
	} else {
		fmt.Printf("Share code: %s\n", code)
		fmt.Printf("Open in LinkaBoo: %s\n", cfg.ShareLink(code))
		fmt.Println("Waiting for receiver...")
	}

	// Block until the transfer completes or is cancelled.
	for result := range resultCh {
		if result.Error != nil {
			exitWithError(jsonMode, jw, result.Error)
		}
		if jsonMode {
			jw.WriteEvent(engine.StatusEvent{Type: engine.EventComplete, OK: true})
		} else {
			fmt.Println("Transfer complete!")
		}
	}
}

func cmdReceive(args []string) {
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "Usage: linkaboo receive <code> [--dest dir] [--json]")
		os.Exit(1)
	}

	code := args[0]
	destDir := flagValue(args[1:], "--dest")
	if destDir == "" {
		destDir = "."
	}
	jsonMode := hasFlag(args[1:], "--json")

	// Validate code format
	if !codePattern.MatchString(code) {
		msg := fmt.Sprintf("invalid share code format: %q (expected like 7-crossword-clockwork)", code)
		if jsonMode {
			jw := engine.NewJSONLineWriter(os.Stdout)
			jw.WriteEvent(engine.StatusEvent{Type: engine.EventError, Message: msg})
		} else {
			fmt.Fprintln(os.Stderr, msg)
		}
		os.Exit(1)
	}

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	jw := engine.NewJSONLineWriter(os.Stdout)
	_, client, err := loadClient()
	if err != nil {
		exitWithError(jsonMode, jw, err)
	}

	if !jsonMode {
		fmt.Printf("Connecting with code: %s\n", code)
	}

	progressFn := func(sent, total int64) {
		if jsonMode {
			var pct float64
			if total > 0 {
				pct = float64(sent) / float64(total) * 100
			}
			jw.WriteProgress(engine.ProgressEvent{
				Type:       engine.EventProgress,
				SentBytes:  sent,
				TotalBytes: total,
				Percent:    pct,
			})
		}
	}

	result, err := engine.Receive(ctx, client, code, destDir, progressFn)
	if err != nil {
		exitWithError(jsonMode, jw, err)
	}

	if jsonMode {
		jw.WriteEvent(engine.StatusEvent{
			Type:      engine.EventComplete,
			OK:        true,
			FileName:  result.Name,
			FileCount: result.FileCount,
		})
	} else {
		switch result.Type {
		case "text":
			fmt.Printf("Received text (%d bytes)\n", result.BytesReceived)
		case "file":
			fmt.Printf("Received file: %s (%d bytes)\n", result.Name, result.BytesReceived)
		case "directory":
			fmt.Printf("Received directory: %s (%d files, %d bytes)\n", result.Name, result.FileCount, result.BytesReceived)
		}
	}
}

func hasFlag(args []string, flag string) bool {
	for _, a := range args {
		if a == flag {
			return true
		}
	}
	return false
}

func flagValue(args []string, flag string) string {
	for i, a := range args {
		if a == flag && i+1 < len(args) {
			return args[i+1]
		}
	}
	return ""
}

func loadClient() (engine.Config, *wh.Client, error) {
	cfg, err := engine.LoadConfigFromEnv()
	if err != nil {
		return engine.Config{}, nil, err
	}
	client := engine.NewClient(cfg)
	return cfg, client, nil
}

func exitWithError(jsonMode bool, jw *engine.JSONLineWriter, err error) {
	message := describeError(err)
	if jsonMode {
		_ = jw.WriteEvent(engine.StatusEvent{Type: engine.EventError, Message: message})
	} else {
		fmt.Fprintf(os.Stderr, "Error: %s\n", message)
	}
	os.Exit(1)
}

func describeError(err error) string {
	if err == nil {
		return "unknown error"
	}

	message := err.Error()
	switch {
	case strings.Contains(message, "failed to establish connection"):
		return "Couldn't establish a direct connection. LinkaBoo doesn't relay file data in this build."
	case strings.Contains(message, "connection refused"):
		return "Couldn't reach the transfer peer. Ask the sender to reopen LinkaBoo and try again."
	default:
		return message
	}
}
