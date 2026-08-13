# LinkaBoo Cost Thesis

LinkaBoo only works as a low-price utility if file bytes stay off company infrastructure.

## Acceptable Ongoing Costs

- domain and DNS
- static site hosting
- lightweight coordination backend
- logs and monitoring with minimal retention

## Dangerous Costs

- TURN or relay bandwidth
- server-side file caching or retention
- browser-first transfer features
- convenience features that proxy payloads through backend services

## Operating Rules

- server coordinates, users provide bandwidth
- no hidden relay in MVP
- no storage service behavior
- no cloud-style “available anytime” promise

If a new feature increases infrastructure responsibility for file bytes, it should be treated as a business-model change, not a small engineering convenience.
