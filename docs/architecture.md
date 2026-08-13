# LinkaBoo Architecture

## Product Shape

LinkaBoo is a native Mac app for direct person-to-person transfer. The product promise depends on keeping responsibilities clean:

- native apps own the transfer UX
- the local engine owns encrypted file movement
- the backend owns coordination only
- the web page owns install/open/status handoff

## Runtime Layers

### Native app

- drag/drop and Finder-adjacent entry points
- review and approval states
- transfer progress, retry, completion, failure
- deep-link entry for receives

### Local transfer engine

- one-time code creation
- direct encrypted transport
- file and directory packaging
- integrity-safe extraction
- structured progress/error events for Swift UI

### Coordination backend

- install registration
- session creation
- link slug resolution
- sender presence heartbeat
- recipient-open events
- short-lived negotiation payloads
- expiry, cancellation, status

### Web handoff page

- resolves handoff link
- explains LinkaBoo transfer model
- prompts install/open
- optionally reflects sender availability

## Hard Rules

- no payload storage on backend
- no hidden relay fallback
- no browser receiver in MVP
- no hosted-download semantics in product copy
- direct-only failure is acceptable; infrastructure creep is not
