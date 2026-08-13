# LinkaBoo Project Memory

This directory preserves the research, product, UX, brand, and development conversations that shaped LinkaBoo. The source chats are stored verbatim in [`chats/`](chats/) so their provenance and changes in direction remain inspectable.

## How to use this memory

1. Start with [`SYNTHESIS.md`](SYNTHESIS.md) for the current product throughline and the most important lessons from the archive.
2. Use the source index below to find the original conversation behind a decision or artifact.
3. Treat the chats as historical inputs, not current specifications. When a chat conflicts with an ADR, `AGENTS.md`, or a current architecture document, the current repository guidance wins.
4. Preserve contradictions that explain how the project evolved. Do not silently rewrite the historical chats to match the present architecture.

## Canonical product guardrails

- Mac-first MVP
- native app required on both ends for meaningful transfer
- direct encrypted P2P app-to-app payload path
- coordination backend only
- browser limited to install, open-app, and status handoff
- no server-side file hosting
- no TURN or hidden payload relay in MVP
- honest direct-connection failure instead of infrastructure drift

## Source index

| Chat | Primary contribution |
| --- | --- |
| [`01-signal-p2p-encryption.md`](chats/01-signal-p2p-encryption.md) | Early encryption research and the initial Signal-versus-transfer-protocol confusion |
| [`02-protocol-selection-strategy.md`](chats/02-protocol-selection-strategy.md) | WebRTC, Magic Wormhole, BitTorrent concepts, and transport tradeoffs |
| [`03-fake-notch-drag-area.md`](chats/03-fake-notch-drag-area.md) | Feasibility of the top-center macOS drag target |
| [`04-linkaboo-mvp-update.md`](chats/04-linkaboo-mvp-update.md) | MVP constraints, direct-transfer reliability, and file-size thinking |
| [`05-creating-communication-protocols.md`](chats/05-creating-communication-protocols.md) | Early architecture, cost model, development planning, and Codex brief creation |
| [`06-cost-avoidance-in-file-sharing.md`](chats/06-cost-avoidance-in-file-sharing.md) | Native-required growth loop, bandwidth avoidance, and platform strategy |
| [`07-app-development-plan.md`](chats/07-app-development-plan.md) | Early project instructions, naming, UI planning, and a superseded hosted-download direction |
| [`08-ios-linkaboo-app-guide.md`](chats/08-ios-linkaboo-app-guide.md) | iOS exploration retained as future-phase research, not MVP scope |
| [`09-download-page-statuses.md`](chats/09-download-page-statuses.md) | Status inventory, public handoff-page thinking, and the development spec |
| [`10-linkaboo-ux-feedback.md`](chats/10-linkaboo-ux-feedback.md) | UX critique, state model, and lightweight product design/PDR work |
| [`11-user-flow-feedback.md`](chats/11-user-flow-feedback.md) | Flow refinement and the detailed MVP outline |
| [`12-logo-option-recommendation.md`](chats/12-logo-option-recommendation.md) | Logo-system refinement and primary lockup decisions |
| [`13-brainstorming-new-name.md`](chats/13-brainstorming-new-name.md) | Character, mascot, logo, file-icon, and status-icon exploration |
| [`14-portal-whirlpool-effect-design.md`](chats/14-portal-whirlpool-effect-design.md) | Early Portal identity and prompts prepared for Midjourney/other generators |
| [`15-project-status-update.md`](chats/15-project-status-update.md) | Restarted UX plan, Finder flow, popover states, snapshots, and branded feedback |
| [`16-office-document-icons.md`](chats/16-office-document-icons.md) | AI-assisted office-document icon exploration and asset extraction work |
| [`17-brand-color-scheme-svg.md`](chats/17-brand-color-scheme-svg.md) | Palette exploration and SVG workflow tooling |

## Current decision sources

- [`../architecture.md`](../architecture.md)
- [`../mvp-scope.md`](../mvp-scope.md)
- [`../cost-thesis.md`](../cost-thesis.md)
- [`../state-model.md`](../state-model.md)
- [`../adr/001-mac-first-native-required.md`](../adr/001-mac-first-native-required.md)
- [`../adr/002-browser-install-gate-only.md`](../adr/002-browser-install-gate-only.md)
- [`../adr/003-no-relay-mvp.md`](../adr/003-no-relay-mvp.md)

