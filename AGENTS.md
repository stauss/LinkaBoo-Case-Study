# LinkaBoo Repo Guidance

Core direction:

- Mac-first MVP
- Native app required for meaningful transfer in v1
- P2P app-to-app transfer only
- No server-side file hosting
- No TURN / relay bandwidth in MVP
- Browser page is install/status handoff only
- Coordination backend only

When planning or implementing:

- reject architecture drift toward cloud storage or browser delivery
- prefer honest failure over hidden relay infrastructure
- protect the low-cost operating model
- preserve a short sender flow
- keep Finder, drag-drop, and native macOS UX first-class
- do not reintroduce iOS-first assumptions into MVP docs unless clearly labeled future phase

Project memory:

- Start with `docs/project-memory/README.md` and `docs/project-memory/SYNTHESIS.md` when historical product context is needed.
- The preserved chats in `docs/project-memory/chats/` are source material, not canonical specifications.
- If historical chat advice conflicts with this file, the ADRs, or current architecture docs, current repository guidance wins.
