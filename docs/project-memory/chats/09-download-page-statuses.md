# Download Page Statuses

Source: https://chatgpt.com/g/g-p-680db7b0dcc48191ac9438262e532bbf-linkaboo/c/69dae8d2-2bc0-83ea-b7d3-dcd277e8251f

---

**Sat, Apr 11 at 7:36 PM**

**User:**
Can you please create a document of all of the different statuses that we need. I also need to work on the download page for when someone does not have the application. Should there be anything different on that page that isnt in the application besides a download now button?

**ChatGPT:**
*(Produced a canvas document titled "LinkaBoo Statuses And Download Page Notes," reproduced below.)*

## LinkaBoo — Status Inventory + Download Page Notes

Date: 2026-04-11

### Purpose
This document defines the product states LinkaBoo should support across the app UI and the browser download experience, with an emphasis on a simple, understandable MVP.

### 1) Core File / Transfer Statuses

**A. Ready / Idle** — Item is available and no transfer is currently happening. Labels: Ready to Share, Available, Waiting. Where used: menu bar panel, share sheet/recent items, download page before action begins. UI notes: neutral styling, no animation, primary action visible.

**B. Preparing** — LinkaBoo is packaging the file, validating access, gathering metadata, or setting up the peer session. Labels: Preparing, Getting Ready, Starting Transfer. Where used: immediately after share begins, before download session starts. UI notes: spinner or subtle activity state; avoid showing for too long without explanatory fallback text.

**C. Discovering Peer** — The app is trying to find or establish the target peer/session. Labels: Looking for Recipient, Connecting, Finding Peer. Where used: app transfer startup, P2P handoff state. UI notes: useful only in-app; probably not needed on the public browser page unless the web page participates in live session setup.

**D. Waiting for Recipient** — The sender is ready, but the receiver has not joined or accepted yet. Labels: Waiting for Recipient, Waiting to Connect, Ready When They Are. Where used: sender view, recent shares list. UI notes: should communicate that the sender does not need to re-share; can optionally show expiration timing.

**E. Waiting for Sender** — Receiver opened the link or app, but the sender is not currently available or has not confirmed. Labels: Waiting for Sender, Sender Not Yet Available, Waiting for File Source. Where used: browser download page, app receive flow. UI notes: important for P2P expectations; explain briefly that transfer starts when both sides are present.

**F. Downloading / Receiving** — The receiver is actively downloading the item. Labels: Downloading, Receiving, Transfer in Progress. Where used: app recent items, browser page. UI notes: show percent, speed, remaining time if stable enough; always support a simple determinate progress bar in MVP.

**G. Uploading / Sending** — The sender is actively transmitting the item. Labels: Sending, Uploading, Transfer in Progress. Where used: sender app view. UI notes: mirror receiving state; same progress semantics on both sides when possible.

**H. Paused** — Transfer is temporarily stopped by the user or due to environmental conditions. Labels: Paused, Transfer Paused. Where used: later-phase feature if pause/resume is supported. UI notes: not required for strict MVP unless resume support exists.

**I. Retrying** — The system lost connection and is attempting to recover automatically. Labels: Reconnecting, Retrying, Trying Again. Where used: app panel, browser session state if reconnect is supported. UI notes: prefer friendly language over technical failure text; show subtle activity indicator.

**J. Complete** — Transfer finished successfully. Labels: Complete, Downloaded, Sent. Where used: app recent items, browser success state. UI notes: strong positive confirmation; secondary action: Show in Finder / Open / Download Again where appropriate.

**K. Canceled** — A transfer was intentionally stopped by the user. Labels: Canceled, Transfer Canceled. Where used: app recent items, browser page if receiver cancels. UI notes: distinct from error; should support restart action when possible.

**L. Expired** — The link or transfer window is no longer valid. Labels: Link Expired, No Longer Available, Share Ended. Where used: browser page, app history. UI notes: this is one of the most important web-only states; explain clearly why it is unavailable.

**M. File Missing** — The original file cannot be found on the sender device. Labels: File Missing, Original File Unavailable. Where used: app recents, browser failure state if sender asset disappeared before transfer. UI notes: good candidate for recovery action: Choose File Again.

**N. Error / Failed** — Transfer could not complete due to a generic failure. Labels: Failed, Transfer Failed, Error. Where used: app recents, browser page. UI notes: use only when a more specific status is not available; always pair with a plain-language explanation when possible.

### 2) Recommended MVP Status Set

To keep the MVP lean, LinkaBoo should probably ship with these primary statuses: Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Complete, Canceled, Expired, File Missing, Error, Retrying.

### 3) Statuses That Matter Most on the Public Download Page

The browser page does not need every app state. It only needs the states relevant to someone opening a shared link.

Essential browser-page states: File available; Waiting for sender; Preparing download; Downloading; Complete; Link expired; File missing; Transfer failed; Download in app (optional alternate path).

### 4) What Should Be Different on the Download Page?

Yes — the download page should include a few things that are not necessary in the app.

**A. Clear trust / explanation block** — because the person may not know LinkaBoo, the page should briefly explain what LinkaBoo is, that this is a direct or secure file transfer, and that no account is required for the download if that is true. This builds confidence and reduces hesitation.

**B. File metadata summary** — the page should show file name, file type, file size, sender name or sender label (if available), and expiration timing (if available). This helps the recipient verify they opened the correct link.

**C. Browser-specific empty / unavailable states** — the web page needs stronger explanation for link expired, sender offline, file removed, transfer interrupted. In the app, users may understand the system already. On the web, they need more context.

**D. "Download the app" CTA** — this should exist, but it should be secondary unless the browser experience is limited. Suggested CTA structure: Primary: Download Now; Secondary: Open in LinkaBoo app; Tertiary: Get the Mac app. If the best experience really requires the app, then "Get the app" can become more prominent.

**E. Lightweight product value proposition** — a short line under the header can help, e.g. "Fast secure file delivery from LinkaBoo," "Shared directly from LinkaBoo," "Private file transfer made simple." This is marketing-adjacent, but useful on the web.

### 5) What the Download Page Does Not Need

To keep it slim, the browser page probably does not need: recent history list; menu bar style status feed; advanced transfer diagnostics; multiple completed item rows; dense settings controls; too many technical details about P2P/encryption. The page should focus on one job: help the recipient trust the link and get the file quickly.

### 6) Recommended Download Page Structure

- **Header** — LinkaBoo mark, short headline, optional trust statement
- **File card** — file icon, name, size, type, sender, expiry
- **Primary action area** — Download Now, Open in App, progress state when active
- **Status / helper text** — sender is online / waiting / unavailable; expired / missing / failed explanations
- **Secondary footer area** — Get LinkaBoo for Mac, brief product note

### 7) Suggested UX Copy Starters

Available: "Ready to download," "This file is available now."
Waiting: "Waiting for the sender to come online," "This transfer will begin once both devices are connected."
Preparing: "Preparing your download."
In progress: "Downloading…," "Receiving file…"
Complete: "Download complete," "Your file is ready."
Expired: "This link has expired," "This file is no longer available."
Missing: "The original file is no longer available."
Failed: "The transfer was interrupted," "Something went wrong while downloading."

### 8) Product Recommendation

For MVP, the download page should do a little more than just add a Download Now button. It should also include: file identity details; trust/explanation copy; sender availability state; expired/missing/failure messaging; optional app download CTA. That is enough to make the page feel complete without turning it into a marketing site.

### 9) Deliverable Tracker

Done: initial status inventory; MVP status recommendation; download page content recommendation.
Next: finalize status naming system; define icon set for each status; write exact UI copy for app + browser states; wireframe the browser download page; decide CTA priority: browser-first vs app-first.

### 10) Proposed Next Step

Create a simple one-page browser download wireframe with these states: Ready to download; Waiting for sender; Downloading; Complete; Expired; File missing.

---

**ChatGPT (follow-up summary):**
I put together a working doc covering the full status set and what should be added to the browser download page.

My recommendation: yes, the download page should include a bit more than just a Download Now button. The key additions are: clear file details so the recipient knows what they're opening; a short trust/explainer line about LinkaBoo; sender/session availability states like waiting, expired, missing, failed; a secondary "Get the app" CTA, not just the file download action.

For MVP, the most important statuses to support are: Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Complete, Canceled, Expired, File Missing, Error, Retrying.

On the public download page, keep it even tighter: Ready to download, Waiting for sender, Preparing, Downloading, Complete, Link expired, File missing, Transfer failed.

The biggest difference between the app and the web page is context. In the app, people already understand the product. On the web page, they need reassurance and clarity right away.

Ready to review a simple wireframe structure for the non-app browser download page next?

---

**User:**
I already have a start on the development of this project (as in I have the wormhole portal functioning)

Can you please outline everything that we need to do so and can use those instructions / specs in convex for Ai development / development support?

**ChatGPT:**
*(Produced a canvas document titled "LinkaBoo Convex AI Dev Spec," reproduced below.)*

## LinkaBoo — Convex AI Development Spec

Date: 2026-04-11 · Version: v0.1

### Purpose
This document is the single working spec for using AI-assisted development on LinkaBoo. It is written to be pasted into Convex, Cursor, Claude, ChatGPT, or other AI development workflows so the model has clear product, technical, UX, and delivery constraints.

### 1. Product Summary
LinkaBoo is a native macOS file-sharing app focused on fast, secure, low-friction peer-to-peer sharing. The current starting point is that a wormhole-style portal flow is already functioning — the product is not starting from zero. The goal now is to turn the current working transfer foundation into a polished, branded, production-quality macOS app with a clean UI, reliable transfer states, and a fallback browser download experience.

Core product idea: share files and folders from macOS with minimal friction; make sharing feel lightweight, instant, and native; support direct app-to-app transfers first; support a browser-based receive/download experience when the recipient does not have the app; keep the UX simple — no heavy dashboards, no unnecessary settings, no account-first complexity for MVP.

Product principles: native-feeling on macOS; very low cognitive load; fast path to sharing; clear transfer states; private and trustworthy; lean MVP before feature expansion.

### 2. Current State

What already exists: a wormhole/portal-style transfer flow is already working; there is already enough technical proof that the sharing concept is viable; the project has an early UI direction and menu-bar/panel style concepts; the product name is now LinkaBoo; brand direction is playful but polished, with a macOS-native feel.

What this means for development: AI should not propose rebuilding the entire system unless clearly necessary. Instead, AI support should focus on organizing the existing architecture, refining the UX, formalizing states and flows, hardening reliability, polishing the macOS app, defining a browser fallback download page, preparing the project for MVP delivery.

### 3. MVP Goal
Build a polished MVP of LinkaBoo for macOS where a user can share a file or folder, generate a shareable link or transfer path, and allow a recipient to receive the item either in the LinkaBoo app or through a simple browser download page.

MVP success criteria: a sender can share a file or folder from macOS easily; a recipient can open the share via app or browser; transfer state is visible and understandable; core errors are recoverable or clearly explained; the UI feels native, minimal, and intentional; branding is consistent across app and web; the product is reliable enough for controlled user testing.

### 4. Scope Boundaries

In scope for MVP: native macOS app; menu bar presence or lightweight desktop utility behavior; drag-and-drop share flow; right-click/share action exploration if feasible; file and folder sharing; recent transfers/recent shared items list; transfer status system; browser fallback download page; clean branding and visual system; basic settings; error handling for core failure states; checks for missing files, expired links, failed transfers, and successful completion.

Out of scope for MVP unless already mostly built: full account system; multi-user social graph; full chat or messaging system; rich profiles and avatars; cross-platform desktop clients beyond macOS; mobile apps; enterprise admin tooling; extensive analytics dashboards; background sync product features; complex collaboration features.

### 5. Required User Flows

**Flow A — Share by drag and drop:** user drags a file or folder on macOS → LinkaBoo widget/target becomes visible/active → user drops the item on LinkaBoo → LinkaBoo prepares the share → creates a share link/session → link is copied to clipboard automatically → UI confirms sharing is active → item appears in recent shares with a live status.

**Flow B — Share from right-click / contextual action:** user right-clicks a file or folder → chooses LinkaBoo/Share with LinkaBoo → LinkaBoo prepares the file → link is generated and copied → confirmation state appears.

**Flow C — Receive in app:** recipient opens LinkaBoo → enters or opens the link/session → app shows file details and readiness → recipient confirms download → transfer begins → progress is shown → completion state allows reveal in Finder.

**Flow D — Receive in browser:** recipient opens the shared LinkaBoo URL → browser page shows file metadata and availability → user downloads the file directly or is guided to the app if needed → page shows progress or transfer state → completion or failure is explained clearly.

**Flow E — Re-open recent item:** user opens LinkaBoo panel → sees recent items with status → can reveal completed item, retry failed share, or inspect status.

### 6. Core UX Requirements

UX principles: one primary action per screen/state; avoid technical jargon unless necessary; use simple labels and short status text; keep the panel compact and glanceable; make progress and failures visible immediately; always provide the next obvious action.

Interaction design priorities: drag-and-drop should feel delightful and obvious; copy-to-clipboard confirmation should be clear; transfer state changes should be visible in real time; success should feel confident but not noisy; errors should be actionable; browser experience should feel trustworthy, not like a dead-end fallback.

macOS design guidance: use macOS conventions wherever possible; prefer SwiftUI-native patterns where they do not fight platform expectations; respect light mode and dark mode equally; use appropriate spacing, typography, icon weight, and hover states; keep panel density high enough to be useful, but not crowded.

### 7. Required Transfer Status System

Primary statuses for MVP: Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Retrying, Complete, Canceled, Expired, File Missing, Error.

Requirements for statuses: every status must have a user-facing label; every status must have optional helper text; every status must have an icon or visual indicator; progress-based statuses should support percent complete; error states should prefer specific explanations over generic failure when possible.

Example status behavior: Preparing (shown while packaging, validating, or starting session); Waiting for Recipient (sender is ready but receiver has not joined); Waiting for Sender (receiver opened page/app but source is not available yet); Retrying (connection dropped and recovery is in progress); Complete (successful transfer with follow-up action like Reveal in Finder); File Missing (original item no longer available locally); Expired (share link/session no longer valid).

### 8. Browser Download Page Requirements

The browser page is not just a download button. It must create trust and clarity for people who do not know the app.

Required content: LinkaBoo branding; file name; file type; file size; sender label if available; availability/status text; primary CTA (Download Now); secondary CTA (Get the Mac app or Open in App).

Required states: Ready to download; Waiting for sender; Preparing download; Downloading; Complete; Link expired; File missing; Transfer failed.

Browser page UX rules: one file per page focus; no dashboard complexity; no unnecessary settings; clear explanation when transfer is unavailable; keep copy simple and confidence-building.

Example trust copy: "Shared securely with LinkaBoo"; "No account required to download"; "This file was shared directly from LinkaBoo." Only include claims that are technically true.

### 9. App Surface Areas To Build or Refine

**A. Share target / drag target UI** — idle state; hover/active state; drop confirmation; preparing state.

**B. Menu bar panel / utility panel** — recent items list; transfer status rows; actions such as Show in Finder, Retry, Copy Link; settings access; version label placement if needed.

**C. Receive / open-link flow** — file summary; destination choice if required; progress state; completion state.

**D. Settings** — link/share expiration duration; default download location; launch at login; notifications on completion/failure; optional clipboard behavior.

**E. Error presentation** — inline row status treatment; lightweight toast/banner use where helpful; retry action for recoverable failures.

### 10. Technical Architecture Requirements

Top-level architecture goals: separate transport logic from UI; separate transfer/session state from presentation; centralize status handling; make the codebase testable; minimize fragile view logic; prefer simple abstractions over premature complexity.

Recommended major modules:
1. **App UI Layer** — SwiftUI views, state presentation, user actions, lightweight view models.
2. **Transfer Service Layer** — start share, accept share, monitor progress, reconnect/retry logic, finalize transfer, surface normalized status events.
3. **Session / Link Manager** — create session identifiers or links, validate session state, expiration handling, session lookup and state transitions.
4. **File Preparation Layer** — inspect file/folder metadata, validate existence and permissions, package or stream content, checksum/integrity support if needed.
5. **Persistence Layer** — recent transfer history, cached metadata, user settings, app preferences.
6. **Browser/Web Layer** — render download page, resolve share metadata, support browser receive flow, show user-facing state transitions.

### 11. State Management Requirements

Requirements: one canonical transfer state enum/model; consistent mapping from backend/service state to UI state; consistent mapping between app and browser terminology; avoid duplicated ad hoc state logic across views.

Transfer model should include: transfer id; file/folder name; item type; byte size; created at; updated at; progress percent; sender/receiver role; current status; human-readable error reason; local file path if applicable; share/session URL if applicable; expiration timestamp if applicable.

### 12. Reliability Requirements

Must handle: recipient opens link before sender is ready; sender goes offline during transfer; local file moves or is deleted; interrupted transfer; invalid or expired link; duplicate open attempts; large file transfers; folder transfers with nested contents.

AI should help design: retry strategy; timeout strategy; cleanup behavior for stale sessions; clear user-facing recovery actions.

### 13. Data / Metadata Requirements

Required metadata: item name; item kind (file or folder); file extension or content category if useful; size; share/session id; created date; expiry date; sender label if available; transfer status; progress; completion date if finished; failure reason if failed.

Optional later: thumbnail/preview; transfer speed; estimated time remaining; recipient label.

### 14. Security / Trust Requirements

Do not make unsupported marketing claims. All security language must match reality.

Required principles: be precise in copy about direct transfer vs relayed transfer; clearly define what metadata is stored and where; ensure any temporary share references are handled safely; avoid exposing unnecessary local path information in public links.

If encryption is included, AI should document: what is encrypted; when encryption happens; what keys or sessions are used; whether the browser fallback changes the trust model.

### 15. Performance Requirements

MVP performance goals: share initiation should feel near-instant for normal files; UI should update transfer state quickly and smoothly; recent items list should remain responsive; browser page should load quickly and show metadata fast.

Optimization guidance: prioritize perceived speed over over-engineering; avoid blocking the UI thread; support streaming or staged preparation for larger items where possible.

### 16. Testing Requirements

Unit tests needed: transfer state mapping; file existence validation; expiration logic; retry logic; metadata generation; URL/session parsing.

Integration tests needed: start share → receive flow; sender available/unavailable transitions; browser link open flow; folder share flow; failure recovery.

UI tests needed: drag target visibility and activation; link copied confirmation; recent items row states; completion action reveals in Finder; browser page state rendering.

Manual QA checklist: share file from drag/drop; share folder from drag/drop; open link in browser; open link in app; test expired link; test missing file; test interrupted transfer; test dark mode and light mode; test small and large files.

### 17. Branding / Visual Requirements

Brand basics: product name LinkaBoo; tone friendly, lightweight, trustworthy, polished; visual direction playful but mature enough for daily utility use; platform feel native macOS first.

UI requirements: consistent icons for statuses; clear hierarchy in recent items rows; strong empty states; good contrast in light and dark mode; compact but breathable spacing.

Assets likely needed: app icon; menu bar icon; drag target states; status icons; browser favicon/lightweight brand assets.

### 18. Copywriting Requirements

All copy should be short, direct, human, non-technical unless necessary, consistent across app and web.

Key copy surfaces: status labels; helper text; button labels; empty states; error messages; completion confirmations; browser trust copy.

Copy examples: "Link copied"; "Ready to share"; "Waiting for sender"; "Download complete"; "File no longer available"; "Try again."

### 19. AI Coding Rules

General rules: do not rewrite working systems without a clear reason; build on the existing wormhole-style implementation; prefer incremental refactors over sweeping rewrites; keep abstractions simple and easy to reason about; explain architectural changes before applying them; when proposing code, include file-by-file changes; preserve current functionality unless a change explicitly replaces it.

Swift / macOS rules: prefer SwiftUI for new UI unless AppKit is clearly required; keep business logic out of views; use async/await where appropriate; use observable state cleanly and consistently; keep view models slim; use strongly typed models for transfer state.

Web page rules: keep the browser page extremely simple; design for one-file/one-share clarity; prefer semantic HTML and minimal JS unless more is needed; focus on state clarity over visual complexity.

Testing rules: any non-trivial change should include or update tests; new state logic should come with unit coverage; shared utilities should not be introduced without tests if they affect transfer behavior.

### 20. AI Task Templates

**Template — architecture review:** "Review this LinkaBoo code and propose a minimal refactor plan that preserves the current wormhole-style transfer functionality while separating UI, transfer service logic, and transfer state modeling. Do not suggest a full rewrite. Return the plan as: current issues, target architecture, file-by-file changes, risks, and migration steps."

**Template — SwiftUI implementation:** "Implement this LinkaBoo UI in SwiftUI using a native macOS feel. Use a clear transfer state model and keep business logic out of the view. Return code organized by file and include any required models or view models."

**Template — status system:** "Design a canonical TransferStatus model for LinkaBoo that supports Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Retrying, Complete, Canceled, Expired, File Missing, and Error. Include Swift enums, associated metadata if needed, and helper functions for UI labels and icons."

**Template — browser page:** "Design and implement a minimal browser download page for LinkaBoo. The page should show branding, file metadata, availability state, a primary Download Now CTA, a secondary Get the Mac app CTA, and clear states for waiting, downloading, complete, expired, missing, and failed. Keep the page simple and trustworthy."

**Template — QA/test generation:** "Given this LinkaBoo feature implementation, generate the unit, integration, and UI test cases needed for MVP quality. Prioritize transfer state correctness, error recovery, missing file handling, expired link behavior, and browser fallback states."

### 21. Development Work Breakdown

**Phase 1 — Audit and stabilize current foundation:** inspect current working wormhole-style implementation; map current architecture; identify fragile areas; identify missing test coverage; define source of truth for transfer state.

**Phase 2 — Formalize product state model:** create canonical transfer status model; map service events to UI states; define browser page state variants; finalize user-facing labels and error copy.

**Phase 3 — Refine core macOS share experience:** finalize drag target behavior; finalize share confirmation flow; build or refine recent items list; add actions like Show in Finder, Retry, Copy Link.

**Phase 4 — Build browser fallback experience:** implement simple download page; add metadata rendering; add status-based state rendering; add app download CTA; validate unsupported/unavailable states.

**Phase 5 — Reliability hardening:** retry handling; timeouts; missing file checks; expired session behavior; interrupted transfer handling.

**Phase 6 — Settings and polish:** expiration settings; clipboard behavior; notifications; launch at login; empty states and final copy pass.

**Phase 7 — Testing and QA:** unit tests; integration tests; UI tests; manual QA run.

### 22. Definition of Done for MVP

A feature or system is done when: it works in the intended share/receive flow; it has clear states; it has basic error handling; it does not obviously regress current working functionality; it includes tests where appropriate; it fits the LinkaBoo UX principles; it works in light and dark mode if user-facing.

MVP is done when: file/folder sharing works reliably from macOS; recipient app flow works; browser fallback flow works; statuses are clear and complete; recent item history is usable; primary errors are handled gracefully; product is polished enough for live user review.

### 23. Asset / Deliverable Tracker

*(Categories listed: Product / UX, Engineering, QA, Brand / Visual — items not itemized in source.)*

### 24. Change Log

**v0.1 — 2026-04-11:** created initial all-in-one AI development spec; framed the project around an already working wormhole-style transfer base; defined MVP scope, statuses, architecture goals, browser page needs, testing needs, and AI coding rules.

### 25. Paste-Ready Short Context Block

Use this short block when an AI tool needs quick context:

> "I am building LinkaBoo, a native macOS file-sharing app. I already have a working wormhole-style portal transfer flow, so do not propose rebuilding from scratch. Help me turn the current foundation into a polished MVP. The product should support drag-and-drop sharing, a lightweight menu bar or utility panel, recent transfer states, and a fallback browser download page for recipients without the app. Prioritize native macOS UX, simple transfer states, reliability, incremental refactors, and testable architecture. The primary transfer states are Ready, Preparing, Waiting for Recipient, Waiting for Sender, Sending, Downloading, Retrying, Complete, Canceled, Expired, File Missing, and Error. Keep the product lean and avoid unnecessary account, chat, or dashboard complexity for MVP."

---

**ChatGPT (follow-up summary):**
Yes — I turned this into a structured, paste-ready development spec you can use as the base instruction set for Convex or any AI dev assistant.

What it covers: current project state, including that the wormhole-style portal already works; MVP scope and what not to rebuild; required user flows; app surfaces to build/refine; canonical transfer status system; browser fallback download page requirements; architecture and state management expectations; reliability, testing, QA, and "definition of done"; AI coding rules so generated output stays incremental and useful; prompt templates you can paste directly into AI tools.

The most important framing for AI tools is this: build on the existing working transfer foundation; do not rewrite from scratch; prioritize incremental refactors, status clarity, macOS polish, and browser fallback.

I also included a short context block at the bottom that is optimized for quick pasting into AI tools when you do not want to send the full spec.

A strong next move is to split this master spec into 3 smaller AI instruction docs: architecture + state model; macOS UI implementation; browser download page + fallback flow. That usually gets much better code output than one giant prompt.

Ready for me to break this into those three paste-ready Convex AI instruction blocks next?
