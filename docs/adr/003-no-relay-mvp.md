# ADR 003: No Relay In MVP

## Decision

LinkaBoo does not use TURN or payload relay infrastructure in MVP.

## Why

- relay bandwidth is the largest hidden operating-cost risk
- a relay fallback would quietly change the business model
- honest failure is preferable to hidden infrastructure creep

## Consequence

If a direct path cannot be established, LinkaBoo reports that clearly and asks users to retry, reopen the app, or use a different network.
