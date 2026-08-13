# LinkaBoo Execution Plan

## Goal

Deliver the Mac-first LinkaBoo MVP as a native P2P transfer app without cloud storage or relay bandwidth.

## Current Phase

- [x] Plan reset
- [x] Transport audit
- [ ] macOS sender flow polish
- [x] receiver app-entry + install gate
- [ ] direct transfer orchestration hardening
- [ ] QA + polish

## Constraints

- no payload storage on backend
- no relay/TURN in MVP
- browser is install/status only
- sender presence must be honest
- native macOS UX first

## Workstreams

- Product/docs
- App architecture
- Transfer engine
- Backend coordination
- Receiver/install handoff
- QA and instrumentation

## Session Checklist

- define scope
- inspect affected files
- update docs first if direction changed
- implement the smallest testable slice
- run tests or validation
- record follow-ups and anti-drift notes
