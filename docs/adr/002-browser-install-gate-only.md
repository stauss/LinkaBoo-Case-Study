# ADR 002: Browser Is Install And Status Handoff Only

## Decision

The shared link may open a branded web page, but that page is not a transfer client in MVP.

## Why

- browser receiving encourages hosted-download expectations
- real browser transfer would likely require WebRTC and later TURN pressure
- the product promise depends on native-first clarity

## Consequence

`web/` should only support:

- open the app
- install the app
- explain sender availability
- show limited non-sensitive transfer context
