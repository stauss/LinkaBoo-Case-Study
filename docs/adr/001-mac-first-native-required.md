# ADR 001: Mac-First, Native-Required MVP

## Decision

LinkaBoo ships MVP as a Mac-first native app. Both sender and receiver are expected to use the app for meaningful transfer.

## Why

- native file and folder handling is core to the product
- Finder and drag/drop are strong native entry points
- browser-first delivery would distort the architecture and cost model

## Consequence

The browser exists for install/open/status handoff, not for receiving payload bytes.
