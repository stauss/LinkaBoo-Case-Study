# LinkaBoo Project Memory Synthesis

## The throughline

LinkaBoo began with a simple frustration: moving a file to another person often requires first uploading it to a third party. The project explored several possible solutions—Signal-style encryption, Magic Wormhole, WebRTC, relay fallback, browser receiving, mobile clients, identity systems, and cloud-like links—before converging on a much more disciplined MVP:

> A Mac-native utility that creates a short handoff and moves file bytes directly between two LinkaBoo apps, while company infrastructure coordinates the introduction but never hosts or relays the payload.

The most important product insight is that privacy, UX, and operating cost are the same architecture problem. Requiring a native app introduces receiver friction, but it enables Finder integration, reliable local file access, native progress and failure states, and a low-cost direct transfer model.

## How AI contributed

AI was used as a working partner across the product cycle:

- expanding an initial idea into product-design requirements (PDRs), MVP outlines, status inventories, acceptance criteria, and implementation briefs
- researching encryption and transfer approaches, then comparing Signal, Magic Wormhole, WebRTC, relay/TURN behavior, BitTorrent concepts, and platform frameworks
- turning large research sets into structured notes and questions for Google NotebookLM notebooks, which were used to synthesize themes, surface actionable decisions, and identify technologies worth prototyping
- challenging platform choices such as React Native versus native shells with a shared Go/Rust-style engine
- exploring names and messaging as the concept moved from Portal to SendLoop and finally LinkaBoo, including the linka.boo wordplay and the shift from “upload” language to “send” and “transfer”
- generating prompts for Midjourney and other visual tools to explore the Portal vortex, ghost mascot, chain/paperclip metaphors, character poses, document icons, palettes, and motion
- translating decisions into Codex-ready plans, ADRs, state models, and implementation tasks

AI output was never treated as authority. Some early recommendations assumed Signal was implemented when it was not, described Magic Wormhole as always relayed, suggested hosted browser downloads, or proposed invisible fallbacks. Those claims were corrected through follow-up questions, protocol research, code inspection, prototypes, and explicit product constraints.

## Decision evolution

### Encryption and transport

The project initially conflated Signal Protocol with file transfer. Research clarified that LinkaBoo's working foundation was Magic Wormhole through `wormhole-william`. The current engine uses Wormhole's short code, PAKE-based key agreement, encrypted control path, and transit mechanism. LinkaBoo then removes the default transit relay in direct-only mode.

### Browser role

Early plans included browser downloads and even encrypted server uploads. Cost and product analysis exposed the contradiction: a convenient hosted link would turn LinkaBoo into the infrastructure it was designed to avoid. The browser was reduced to an honest install/open/status handoff.

### Relay policy

Several conversations recommended an invisible fallback because it improves completion rates. The project ultimately rejected that advice for MVP. A relay still consumes company bandwidth even when payloads are encrypted. Direct connection failure is therefore visible and actionable rather than silently subsidized.

### Platform scope

An iOS plan and cross-platform options were explored. Desktop integration proved to be the differentiator: Finder, drag and drop, menu bar presence, deep links, background process control, and local destinations. The MVP returned to native macOS, with cross-platform and iOS work clearly deferred.

### Product language

Earlier prototypes used “upload” and “download” because those verbs were familiar. Once the architecture solidified, the language changed to “send,” “receive,” “transfer,” and “open in LinkaBoo.” This keeps the interface from implying that a hosted copy exists.

## Actionable product principles

1. Keep the sender ritual extremely short: drag or choose a file, receive a one-time link, share it.
2. Require both native apps and be clear when the sender must remain available.
3. Treat recent activity as transfer history, not a file library.
4. Connect each visible state to a real engine event.
5. Make failure explain what happened, whether it can be retried, and what to do next.
6. Use Boo as functional state language—ready, carrying, transferring, celebrating, or alerting—not decoration.
7. Evaluate any feature that touches payload bytes as an architecture and business-model decision.
8. Keep future ideas—trusted contacts, automatic delivery, shared folders, sync, browser receiving, relays, and iOS—explicitly separated from MVP claims.

## Technology decisions surfaced by the process

- **Swift + AppKit:** macOS lifecycle, menu bar, panels, drag/drop, Finder integration, deep links
- **SwiftUI:** transfer history, settings, reusable state views
- **Go:** portable local transfer engine and CLI
- **Magic Wormhole / `wormhole-william`:** one-time code, authenticated key exchange, encrypted transfer foundation
- **JSON line events:** simple contract between the Go process and native UI
- **XcodeGen:** reproducible native project configuration
- **Static HTML/CSS/JavaScript:** intentionally small browser handoff surface
- **Coordination backend contract:** short-lived session and presence data only

## Open work

- harden direct connection negotiation, retries, and error detail
- complete end-to-end deep-link receiving QA
- verify cancellation, file-missing history, relaunch persistence, and settings behavior
- define destination collision behavior
- test large files and directories under realistic network conditions
- replace development rendezvous dependencies with LinkaBoo-owned coordination
- prepare accessibility, instrumentation, signing, notarization, packaging, and distribution

