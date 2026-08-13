# LinkaBoo — Convex AI Development Spec
_Date: 2026-04-11_
_Version: v0.1_

## Purpose
This document is the single working spec for using AI-assisted development on LinkaBoo.

It is written to be pasted into Convex, Cursor, Claude, ChatGPT, or other AI development workflows so the model has clear product, technical, UX, and delivery constraints.

---

# 1. Product Summary

LinkaBoo is a native macOS file-sharing app focused on fast, secure, low-friction peer-to-peer sharing.

The current starting point is that a **wormhole-style portal flow is already functioning**. That means the product is not starting from zero. The goal now is to turn the current working transfer foundation into a polished, branded, production-quality macOS app with a clean UI, reliable transfer states, and a fallback browser download experience.

## Core product idea
- Share files and folders from macOS with minimal friction.
- Make sharing feel lightweight, instant, and native.
- Support direct app-to-app transfers first.
- Support a browser-based receive/download experience when the recipient does not have the app.
- Keep the UX simple: no heavy dashboards, no unnecessary settings, no account-first complexity for MVP.

## Product principles
- Native-feeling on macOS
- Very low cognitive load
- Fast path to sharing
- Clear transfer states
- Private and trustworthy
- Lean MVP before feature expansion

---

# 2. Current State

## What already exists
- A wormhole / portal-style transfer flow is already working.
- There is already enough technical proof that the sharing concept is viable.
- The project has an early UI direction and menu-bar / panel style concepts.
- The product name is now **LinkaBoo**.
- Brand direction is playful but polished, with a macOS-native feel.

## What this means for development
AI should not propose rebuilding the entire system unless clearly necessary.

Instead, AI support should focus on:
- organizing the existing architecture
- refining the UX
- formalizing states and flows
- hardening reliability
- polishing the macOS app
- defining a browser fallback download page
- preparing the project for MVP delivery

---

# 3. MVP Goal

Build a polished MVP of LinkaBoo for macOS where a user can share a file or folder, generate a shareable link or transfer path, and allow a recipient to receive the item either in the LinkaBoo app or through a simple browser download page.

## MVP success criteria
- A sender can share a file or folder from macOS easily.
- A recipient can open the share via app or browser.
- Transfer state is visible and understandable.
- Core errors are recoverable or clearly explained.
- The UI feels native, minimal, and intentional.
- Branding is consistent across app and web.
- The product is reliable enough for controlled user testing.

---

# 4. Scope Boundaries

## In scope for MVP
- Native macOS app
- Menu bar presence or lightweight desktop utility behavior
- Drag-and-drop share flow
- Right-click / share action exploration if feasible
- File and folder sharing
- Recent transfers / recent shared items list
- Transfer status system
- Browser fallback download page
- Clean branding and visual system
- Basic settings
- Error handling for core failure states
- Checks for missing files, expired links, failed transfers, and successful completion

## Out of scope for MVP unless already mostly built
- Full account system
- Multi-user social graph
- Full chat or messaging system
- Rich profiles and avatars
- Cross-platform desktop clients beyond macOS
- Mobile apps
- Enterprise admin tooling
- Extensive analytics dashboards
- Background sync product features
- Complex collaboration features

---

# 5. Required User Flows

## Flow A — Share by drag and drop
1. User drags a file or folder on macOS.
2. LinkaBoo widget or target becomes visible / active.
3. User drops the item on LinkaBoo.
4. LinkaBoo prepares the share.
5. LinkaBoo creates a share link / session.
6. Link is copied to clipboard automatically.
7. UI confirms that sharing is active.
8. The item appears in recent shares with a live status.

## Flow B — Share from right-click / contextual action
1. User right-clicks a file or folder.
2. User chooses LinkaBoo / Share with LinkaBoo.
3. LinkaBoo prepares the file.
4. Link is generated and copied.
5. Confirmation state appears.

## Flow C — Receive in app
1. Recipient opens LinkaBoo.
2. Recipient enters or opens the link/session.
3. App shows file details and readiness.
4. Recipient confirms download.
5. Transfer begins.
6. Progress is shown.
7. Completion state allows reveal in Finder.

## Flow D — Receive in browser
1. Recipient opens the shared LinkaBoo URL.
2. Browser page shows file metadata and availability.
3. User downloads the file directly or is guided to the app if needed.
4. Page shows progress or transfer state.
5. Completion or failure is explained clearly.

## Flow E — Re-open recent item
1. User opens LinkaBoo panel.
2. User sees recent items with status.
3. User can reveal completed item, retry failed share, or inspect status.

---

# 6. Core UX Requirements

## UX principles
- One primary action per screen/state
- Avoid technical jargon unless necessary
- Use simple labels and short status text
- Keep the panel compact and glanceable
- Make progress and failures visible immediately
- Always provide the next obvious action

## Interaction design priorities
- Drag-and-drop should feel delightful and obvious
- Copy-to-clipboard confirmation should be clear
- Transfer state changes should be visible in real time
- Success should feel confident but not noisy
- Errors should be actionable
- Browser experience should feel trustworthy, not like a dead-end fallback

## macOS design guidance
- Use macOS conventions wherever possible
- Prefer SwiftUI-native patterns where they do not fight platform expectations
- Respect light mode and dark mode equally
- Use appropriate spacing, typography, icon weight, and hover states
- Keep panel density high enough to be useful, but not crowded

---

# 7. Required Transfer Status System

The app and web page must support a clear status model.

## Primary statuses for MVP
- Ready
- Preparing
- Waiting for Recipient
- Waiting for Sender
- Sending
- Downloading
- Retrying
- Complete
- Canceled
- Expired
- File Missing
- Error

## Requirements for statuses
- Every status must have a user-facing label.
- Every status must have optional helper text.
- Every status must have an icon or visual indicator.
- Progress-based statuses should support percent complete.
- Error states should prefer specific explanations over generic failure when possible.

## Example status behavior
- **Preparing**: shown while packaging, validating, or starting session
- **Waiting for Recipient**: sender is ready but receiver has not joined
- **Waiting for Sender**: receiver opened page/app but source is not available yet
- **Retrying**: connection dropped and recovery is in progress
- **Complete**: successful transfer with follow-up action like Reveal in Finder
- **File Missing**: original item no longer available locally
- **Expired**: share link/session no longer valid

---

# 8. Browser Download Page Requirements

The browser page is not just a download button. It must create trust and clarity for people who do not know the app.

## Required content
- LinkaBoo branding
- File name
- File type
- File size
- Sender label if available
- Availability / status text
- Primary CTA: Download Now
- Secondary CTA: Get the Mac app or Open in App

## Required states
- Ready to download
- Waiting for sender
- Preparing download
- Downloading
- Complete
- Link expired
- File missing
- Transfer failed

## Browser page UX rules
- One file per page focus
- No dashboard complexity
- No unnecessary settings
- Clear explanation when transfer is unavailable
- Keep copy simple and confidence-building

## Example trust copy
- Shared securely with LinkaBoo
- No account required to download
- This file was shared directly from LinkaBoo

Only include claims that are technically true.

---

# 9. App Surface Areas To Build or Refine

## A. Share target / drag target UI
Needs:
- idle state
- hover / active state
- drop confirmation
- preparing state

## B. Menu bar panel / utility panel
Needs:
- recent items list
- transfer status rows
- actions such as Show in Finder, Retry, Copy Link
- settings access
- version label placement if needed

## C. Receive / open-link flow
Needs:
- file summary
- destination choice if required
- progress state
- completion state

## D. Settings
MVP settings likely include:
- link/share expiration duration
- default download location
- launch at login
- notifications on completion/failure
- optional clipboard behavior

## E. Error presentation
Needs:
- inline row status treatment
- lightweight toast/banner use where helpful
- retry action for recoverable failures

---

# 10. Technical Architecture Requirements

AI should help evolve the existing working transfer implementation into a maintainable architecture.

## Top-level architecture goals
- Separate transport logic from UI
- Separate transfer/session state from presentation
- Centralize status handling
- Make the codebase testable
- Minimize fragile view logic
- Prefer simple abstractions over premature complexity

## Recommended major modules

### 1. App UI Layer
Responsibilities:
- SwiftUI views
- state presentation
- user actions
- lightweight view models

### 2. Transfer Service Layer
Responsibilities:
- start share
- accept share
- monitor progress
- reconnect/retry logic
- finalize transfer
- surface normalized status events

### 3. Session / Link Manager
Responsibilities:
- create session identifiers or links
- validate session state
- expiration handling
- session lookup and state transitions

### 4. File Preparation Layer
Responsibilities:
- inspect file/folder metadata
- validate existence and permissions
- package or stream content
- checksum/integrity support if needed

### 5. Persistence Layer
Responsibilities:
- recent transfer history
- cached metadata
- user settings
- app preferences

### 6. Browser/Web Layer
Responsibilities:
- render download page
- resolve share metadata
- support browser receive flow
- show user-facing state transitions

---

# 11. State Management Requirements

A shared and explicit state model should exist for transfers.

## Requirements
- One canonical transfer state enum/model
- Consistent mapping from backend/service state to UI state
- Consistent mapping between app and browser terminology
- Avoid duplicated ad hoc state logic across views

## Transfer model should include
- transfer id
- file/folder name
- item type
- byte size
- created at
- updated at
- progress percent
- sender/receiver role
- current status
- human-readable error reason
- local file path if applicable
- share/session URL if applicable
- expiration timestamp if applicable

---

# 12. Reliability Requirements

The product needs to feel dependable even if the underlying network path is imperfect.

## Must handle
- recipient opens link before sender is ready
- sender goes offline during transfer
- local file moves or is deleted
- interrupted transfer
- invalid or expired link
- duplicate open attempts
- large file transfers
- folder transfers with nested contents

## AI should help design
- retry strategy
- timeout strategy
- cleanup behavior for stale sessions
- clear user-facing recovery actions

---

# 13. Data / Metadata Requirements

For each shared item, the system should support enough metadata for a good UX.

## Required metadata
- item name
- item kind: file or folder
- file extension or content category if useful
- size
- share/session id
- created date
- expiry date
- sender label if available
- transfer status
- progress
- completion date if finished
- failure reason if failed

## Optional later
- thumbnail/preview
- transfer speed
- estimated time remaining
- recipient label

---

# 14. Security / Trust Requirements

Do not make unsupported marketing claims. All security language must match reality.

## Required principles
- Be precise in copy about direct transfer vs relayed transfer
- Clearly define what metadata is stored and where
- Ensure any temporary share references are handled safely
- Avoid exposing unnecessary local path information in public links

## If encryption is included
AI should document:
- what is encrypted
- when encryption happens
- what keys or sessions are used
- whether the browser fallback changes the trust model

---

# 15. Performance Requirements

## MVP performance goals
- Share initiation should feel near-instant for normal files
- UI should update transfer state quickly and smoothly
- Recent items list should remain responsive
- Browser page should load quickly and show metadata fast

## Optimization guidance
- prioritize perceived speed over over-engineering
- avoid blocking the UI thread
- support streaming or staged preparation for larger items where possible

---

# 16. Testing Requirements

AI support should generate tests, not just product code.

## Unit tests needed
- transfer state mapping
- file existence validation
- expiration logic
- retry logic
- metadata generation
- URL/session parsing

## Integration tests needed
- start share → receive flow
- sender available / unavailable transitions
- browser link open flow
- folder share flow
- failure recovery

## UI tests needed
- drag target visibility and activation
- link copied confirmation
- recent items row states
- completion action reveals in Finder
- browser page state rendering

## Manual QA checklist
- share file from drag/drop
- share folder from drag/drop
- open link in browser
- open link in app
- test expired link
- test missing file
- test interrupted transfer
- test dark mode and light mode
- test small and large files

---

# 17. Branding / Visual Requirements

## Brand basics
- Product name: LinkaBoo
- Tone: friendly, lightweight, trustworthy, polished
- Visual direction: playful but mature enough for daily utility use
- Platform feel: native macOS first

## UI requirements
- consistent icons for statuses
- clear hierarchy in recent items rows
- strong empty states
- good contrast in light and dark mode
- compact but breathable spacing

## Assets likely needed
- app icon
- menu bar icon
- drag target states
- status icons
- browser favicon / lightweight brand assets

---

# 18. Copywriting Requirements

All copy should be:
- short
- direct
- human
- non-technical unless necessary
- consistent across app and web

## Key copy surfaces
- status labels
- helper text
- button labels
- empty states
- error messages
- completion confirmations
- browser trust copy

## Copy examples
- Link copied
- Ready to share
- Waiting for sender
- Download complete
- File no longer available
- Try again

---

# 19. AI Coding Rules

Use the following rules for AI development support.

## General rules
- Do not rewrite working systems without a clear reason.
- Build on the existing wormhole-style implementation.
- Prefer incremental refactors over sweeping rewrites.
- Keep abstractions simple and easy to reason about.
- Explain architectural changes before applying them.
- When proposing code, include file-by-file changes.
- Preserve current functionality unless a change explicitly replaces it.

## Swift / macOS rules
- Prefer SwiftUI for new UI unless AppKit is clearly required.
- Keep business logic out of views.
- Use async/await where appropriate.
- Use observable state cleanly and consistently.
- Keep view models slim.
- Use strongly typed models for transfer state.

## Web page rules
- Keep the browser page extremely simple.
- Design for one-file/one-share clarity.
- Prefer semantic HTML and minimal JS unless more is needed.
- Focus on state clarity over visual complexity.

## Testing rules
- Any non-trivial change should include or update tests.
- New state logic should come with unit coverage.
- Shared utilities should not be introduced without tests if they affect transfer behavior.

---

# 20. AI Task Templates

These prompts can be pasted into AI tools during development.

## Template — architecture review
"Review this LinkaBoo code and propose a minimal refactor plan that preserves the current wormhole-style transfer functionality while separating UI, transfer service logic, and transfer state modeling. Do not suggest a full rewrite. Return the plan as: current issues, target architecture, file-by-file changes, risks, and migration steps."

## Template — SwiftUI implementation
"Implement this LinkaBoo UI in SwiftUI using a native macOS feel. Use a clear transfer state model and keep business logic out of the view. Return code organized by file and include any required models or view models."

## Template — status system
"Design a canonical TransferStatus model for LinkaBoo that supports Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Retrying, Complete, Canceled, Expired, File Missing, and Error. Include Swift enums, associated metadata if needed, and helper functions for UI labels and icons."

## Template — browser page
"Design and implement a minimal browser download page for LinkaBoo. The page should show branding, file metadata, availability state, a primary Download Now CTA, a secondary Get the Mac app CTA, and clear states for waiting, downloading, complete, expired, missing, and failed. Keep the page simple and trustworthy."

## Template — QA/test generation
"Given this LinkaBoo feature implementation, generate the unit, integration, and UI test cases needed for MVP quality. Prioritize transfer state correctness, error recovery, missing file handling, expired link behavior, and browser fallback states."

---

# 21. Development Work Breakdown

## Phase 1 — Audit and stabilize current foundation
- inspect current working wormhole-style implementation
- map current architecture
- identify fragile areas
- identify missing test coverage
- define source of truth for transfer state

## Phase 2 — Formalize product state model
- create canonical transfer status model
- map service events to UI states
- define browser page state variants
- finalize user-facing labels and error copy

## Phase 3 — Refine core macOS share experience
- finalize drag target behavior
- finalize share confirmation flow
- build or refine recent items list
- add actions like Show in Finder, Retry, Copy Link

## Phase 4 — Build browser fallback experience
- implement simple download page
- add metadata rendering
- add status-based state rendering
- add app download CTA
- validate unsupported / unavailable states

## Phase 5 — Reliability hardening
- retry handling
- timeouts
- missing file checks
- expired session behavior
- interrupted transfer handling

## Phase 6 — Settings and polish
- expiration settings
- clipboard behavior
- notifications
- launch at login
- empty states and final copy pass

## Phase 7 — Testing and QA
- unit tests
- integration tests
- UI tests
- manual QA run

---

# 22. Definition of Done for MVP

A feature or system is done when:
- it works in the intended share/receive flow
- it has clear states
- it has basic error handling
- it does not obviously regress current working functionality
- it includes tests where appropriate
- it fits the LinkaBoo UX principles
- it works in light and dark mode if user-facing

MVP is done when:
- file/folder sharing works reliably from macOS
- recipient app flow works
- browser fallback flow works
- statuses are clear and complete
- recent item history is usable
- primary errors are handled gracefully
- product is polished enough for live user review

---

# 23. Asset / Deliverable Tracker

## Product / UX
- [ ] finalized user flow diagrams
- [ ] final status naming system
- [ ] app row states and action design
- [ ] browser download page wireframe
- [ ] final UX copy

## Engineering
- [ ] current architecture audit
- [ ] canonical transfer state model
- [ ] refactored service boundaries
- [ ] recent history persistence
- [ ] browser page implementation
- [ ] settings implementation
- [ ] error/retry behavior

## QA
- [ ] unit test coverage for state logic
- [ ] integration tests for share/receive flow
- [ ] UI tests for key app screens
- [ ] manual QA checklist completed

## Brand / Visual
- [ ] final menu bar icon
- [ ] drag target visual system
- [ ] status icon set
- [ ] browser page visual styling

---

# 24. Change Log

## v0.1 — 2026-04-11
- Created initial all-in-one AI development spec
- Framed the project around an already working wormhole-style transfer base
- Defined MVP scope, statuses, architecture goals, browser page needs, testing needs, and AI coding rules

---

# 25. Paste-Ready Short Context Block

Use this short block when an AI tool needs quick context:

"I am building LinkaBoo, a native macOS file-sharing app. I already have a working wormhole-style portal transfer flow, so do not propose rebuilding from scratch. Help me turn the current foundation into a polished MVP. The product should support drag-and-drop sharing, a lightweight menu bar or utility panel, recent transfer states, and a fallback browser download page for recipients without the app. Prioritize native macOS UX, simple transfer states, reliability, incremental refactors, and testable architecture. The primary transfer states are Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Retrying, Complete, Canceled, Expired, File Missing, and Error. Keep the product lean and avoid unnecessary account, chat, or dashboard complexity for MVP."
