package engine

import (
	"errors"
	"fmt"
	"net/url"
	"os"
	"strings"

	wh "github.com/psanford/wormhole-william/wormhole"
)

const (
	DefaultAppID       = "app.linkaboo/transfer"
	DefaultLinkBaseURL = "https://linkaboo.app/r"
)

// Config controls how the local transfer engine talks to rendezvous services.
type Config struct {
	AppID               string
	RendezvousURL       string
	TransitRelayAddress string
	LinkBaseURL         string
	Environment         string
	DirectOnly          bool
}

// LoadConfigFromEnv loads explicit transport settings for the current process.
func LoadConfigFromEnv() (Config, error) {
	env := strings.ToLower(strings.TrimSpace(os.Getenv("LINKABOO_ENV")))
	if env == "" {
		env = "development"
	}

	cfg := Config{
		AppID:               firstNonEmpty(os.Getenv("LINKABOO_APP_ID"), DefaultAppID),
		RendezvousURL:       strings.TrimSpace(os.Getenv("LINKABOO_RENDEZVOUS_URL")),
		TransitRelayAddress: strings.TrimSpace(os.Getenv("LINKABOO_TRANSIT_RELAY_ADDRESS")),
		LinkBaseURL:         firstNonEmpty(strings.TrimSpace(os.Getenv("LINKABOO_LINK_BASE_URL")), DefaultLinkBaseURL),
		Environment:         env,
		DirectOnly:          !envBool("LINKABOO_ALLOW_RELAY"),
	}

	if cfg.RendezvousURL == "" {
		if cfg.Environment == "production" {
			return Config{}, errors.New("LINKABOO_RENDEZVOUS_URL is required in production")
		}
		cfg.RendezvousURL = wh.DefaultRendezvousURL
	}

	if err := cfg.Validate(); err != nil {
		return Config{}, err
	}

	return cfg, nil
}

// Validate ensures the configuration does not silently opt into hosted transfer behavior.
func (c Config) Validate() error {
	if strings.TrimSpace(c.AppID) == "" {
		return errors.New("app ID cannot be empty")
	}
	if strings.TrimSpace(c.RendezvousURL) == "" {
		return errors.New("rendezvous URL cannot be empty")
	}
	if _, err := url.Parse(c.RendezvousURL); err != nil {
		return fmt.Errorf("invalid rendezvous URL: %w", err)
	}
	if _, err := url.Parse(c.ShareLink("example-code")); err != nil {
		return fmt.Errorf("invalid link base URL: %w", err)
	}
	if !c.DirectOnly && strings.TrimSpace(c.TransitRelayAddress) == "" {
		return errors.New("relay transport requires LINKABOO_TRANSIT_RELAY_ADDRESS")
	}
	return nil
}

// ShareLink builds the branded app handoff URL for a one-time share code.
func (c Config) ShareLink(code string) string {
	base := strings.TrimRight(strings.TrimSpace(c.LinkBaseURL), "/")
	return base + "/" + url.PathEscape(code)
}

// NewClient constructs a wormhole client using explicit LinkaBoo transport settings.
func NewClient(cfg Config) *wh.Client {
	if cfg.DirectOnly {
		wh.DefaultTransitRelayAddress = ""
	}

	client := &wh.Client{
		AppID:         cfg.AppID,
		RendezvousURL: cfg.RendezvousURL,
	}
	if !cfg.DirectOnly {
		client.TransitRelayAddress = cfg.TransitRelayAddress
	}
	return client
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return strings.TrimSpace(value)
		}
	}
	return ""
}

func envBool(key string) bool {
	switch strings.ToLower(strings.TrimSpace(os.Getenv(key))) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}
