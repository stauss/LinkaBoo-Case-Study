package engine

import (
	"testing"
)

func TestConfigDefaultsToDirectOnly(t *testing.T) {
	t.Setenv("LINKABOO_ENV", "development")
	t.Setenv("LINKABOO_RENDEZVOUS_URL", "")
	t.Setenv("LINKABOO_ALLOW_RELAY", "")

	cfg, err := LoadConfigFromEnv()
	if err != nil {
		t.Fatalf("LoadConfigFromEnv returned error: %v", err)
	}

	if !cfg.DirectOnly {
		t.Fatalf("expected DirectOnly to default to true")
	}
	if cfg.TransitRelayAddress != "" {
		t.Fatalf("expected transit relay to be empty by default")
	}
	if cfg.ShareLink("7-crossword-clockwork") != "https://linkaboo.app/r/7-crossword-clockwork" {
		t.Fatalf("unexpected share link: %s", cfg.ShareLink("7-crossword-clockwork"))
	}
}

func TestConfigRequiresRendezvousInProduction(t *testing.T) {
	t.Setenv("LINKABOO_ENV", "production")
	t.Setenv("LINKABOO_RENDEZVOUS_URL", "")

	if _, err := LoadConfigFromEnv(); err == nil {
		t.Fatalf("expected production config to require LINKABOO_RENDEZVOUS_URL")
	}
}

func TestRelayRequiresExplicitAddress(t *testing.T) {
	cfg := Config{
		AppID:         DefaultAppID,
		RendezvousURL: "ws://localhost:4000/v1",
		LinkBaseURL:   DefaultLinkBaseURL,
		Environment:   "development",
		DirectOnly:    false,
	}

	if err := cfg.Validate(); err == nil {
		t.Fatalf("expected relay-enabled config without address to fail validation")
	}
}
