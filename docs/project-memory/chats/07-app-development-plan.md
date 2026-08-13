# App Development Plan

Source: https://chatgpt.com/g/g-p-680db7b0dcc48191ac9438262e532bbf-linkaboo/c/680e1703-c258-8011-99cd-2c95e2da7712

---

**Apr 27, 2025 at 6:37 AM**

**User:**
Can you please create a set of instructions for the native Mac application that we have been working on named portal. First thing that we need to do is redo the name and come up with something that is catchy and means sending or giving something to someone from someone else. Please add in everything that we have done so far. As the current state or we have successfully integrated the new p2p signal protocol, next we are going to need to get the ui updated to work with the new code. From there we will be working on redesigning the app to make a better Ui/UX an implementing some features that we thought might now come until phase 2. Before we do those features though we are going to need to get a web server up and running (or at least one page that does routing) for the people who do not have the app and would like to download the file from a link. Please create a set of instructions that allows us to stay on topic and on task and something that will create the best app for us

**ChatGPT:**
Here's a structured, step-by-step set of project instructions for the native macOS file-sharing app (formerly "Portal"), so you can stay focused, track what's been done, and know exactly what comes next:

**1. Rename & Rebrand**

Goal: pick a name that instantly evokes "sending/giving from one person to another."

Brainstorm session (team or solo): list 10–15 candidate names (e.g. "Sendify," "GiftPort," "HandOff," "ShareLoop," "PassAlong"); for each, check domain availability & macOS Bundle-ID uniqueness; run a quick gut-check: is it short, memorable, and pronounceable?

Decision criteria: meaning, brevity, domain/Bundle-ID clean, trademark risk low.

Action: once chosen, globally rename Workspace/target, update App Bundle settings, icons, and documentation.

**2. State of the App**

Completed: integrated the new peer-to-peer Signal-protocol layer for end-to-end encryption.
Next: surface that protocol in the UI and wire up controls.

**3. Update the UI for the New Protocol**

Switch to SwiftUI (if not already): audit existing AppKit/UIKit views; scaffold equivalent SwiftUI views; use Combine or async/await to bind your Signal-protocol client state (connecting, connected, error) into the view.

Key screens to update: "Send File" screen (show peer discovery, connection status); "Receive File" screen (QR-code scanner or peer list); global "Status" indicator in menu bar.

**4. Redesign UI/UX (Phase 1)**

User flows: map out "Send" and "Receive" journeys end-to-end.
Wireframes: sketch low-fi layouts for each step.
High-fi mockups: refine visual hierarchy, controls, typography.
Prototype & test: recruit 2–3 users to click through flows and gather feedback.

**5. Web Server for Non-App Users**

Choose tech stack: Swift/Vapor (keeps you in Swift ecosystem) or Node/Express (faster prototyping).
Scaffold server: create a single-page app (SPA) or simple HTML page; add routing for `GET /download/:fileID`; serve a branded landing page with a "Download" button pointing to that route.
Integrate with macOS app: when a user shares a file, generate a unique fileID, upload the encrypted blob to your server, then copy the public link to clipboard.
Deploy: for MVP, host on Heroku, Render, or a small VPS.

**6. Phase 2 & Beyond (Planning Only)**

Delayed features (pick from your Phase 2 wish-list): persistent "favorites" or "trusted peers" list; background transfer resume; auto-update mechanism; profile avatars & user accounts; in-app chat/messages. Note: don't start these until core share/receive + web-download are solid and tested.

**7. Workflow & Collaboration**

Git branching: `main` (always deployable), `feature/rename`, `feature/ui-update`, `feature/server`.
Code reviews: every PR must be reviewed by at least one teammate.
CI: run SwiftLint and unit tests on every push.
QA checklist: encryption handshake success; file integrity post-transfer; download page works in major browsers; UI responds to offline/online transitions.

Stay on task by tackling one bullet at a time, tracking completion in your project board (e.g. GitHub Projects or Trello), and syncing weekly on progress and any blockers. Good luck building the best, most seamless P2P sharing app!

---

**User:**
Can you please add something like this in this format thats a bit more detailed than what you lat posted?

*(User pasted a reference example — a "Project Instructions" template for an unrelated project, "Caleb Stauss Portfolio Build," covering discovery & strategy, information architecture, project selection & case-study framework, content & copy guidelines, visual & interaction direction, marketing & outreach, workflow rules for ChatGPT, and an inspiration shortlist. Reproduced below as provided.)*

> **PROJECT: "Caleb Stauss Portfolio Build"**
>
> Mission: Help Caleb Stauss plan, create, and launch a best-in-class personal portfolio site that showcases his digital, UI/UX, and product-design expertise—and positions him for top-tier roles.
>
> **1 Discovery & Strategy** — Brand Recap; Goals; Competitive Audit (A-level agencies: Oyedrops, BB Agency, Outloud, Love & Money, MB Studio; digital & interactive inspiration: Locomotive, Collins, Rejouice, Plus-Ex; individual designer references: Anton Repponen, Aaron Poe, Hugo Ferradas, etc.); Persona Mapping; Success Metrics.
>
> **2 Information Architecture** — Page Map (Landing/Home, Work/Case Studies hub, 3–5 deep-dive case studies, About/Bio, Process/Approach, Contact/CTA); Navigation Principles; Wireframe Briefs.
>
> **3 Project Selection & Case-Study Framework** — Project Scoring Matrix; Case-Study Template (Hero, Problem & Context, Role & Scope, Process Deep-Dive, Outcome & Metrics, Reflection); Asset Checklist.
>
> **4 Content & Copy Guidelines** — Voice; Length; SEO & Accessibility; Microcopy; Self-Marketing Hooks.
>
> **5 Visual & Interaction Direction** — Design System; Showcase Motion; Responsiveness; Case-Study Layout; Implementation Stack (Framer or Next.js + headless CMS).
>
> **6 Marketing & Outreach** — Target-Company Persona Sheets; LinkedIn & Email Scripts; SEO Snippets & Social Cards; Launch Checklist.
>
> **7 Workflow Rules for ChatGPT** — Interactive Mode; Asset Tracker; Version Control; Source Tagging; Iteration Pace.
>
> Inspiration Shortlist: Plus-Ex, Locomotive, Collins, Oyedrops, BB Agency, Anton Repponen (guglieri.com), and others.

**ChatGPT:**
Below is a ready-to-paste "Project Instructions" block you can drop into a new ChatGPT thread (or into a custom GPT's system/instructions field) for our native macOS P2P file-sharing app (formerly "Portal"). It's detailed, step-by-step, and keeps us laser-focused.

**PROJECT: "SendLoop (formerly Portal) – Native macOS P2P File-Sharing"**

Mission: deliver a polished, end-to-end encrypted peer-to-peer file-sharing app for macOS—with a sleek UI/UX, robust Signal-protocol backbone, and a simple web download page for non-app users.

**1 Naming & Branding**

1. Brainstorm & Selection — generate 10–15 name ideas evoking "sending/giving" (e.g. SendLoop, HandOff, PassAlong, GiftPort); check domain availability, macOS Bundle-ID conflicts, and trademark risk; run a quick pronounceability & memorability test with colleagues.
2. Global Rename — update Xcode targets, Bundle Identifier, Info.plist, and icons; replace all "Portal" references in docs, README, and UI placeholders.
3. Visual Identity — choose a primary accent color and icon motif (e.g., looping arrow); produce light + dark mode variants for logo and launch screen.

**2 Technical Foundation**

1. Completed — Signal-protocol layer integrated for end-to-end encryption & key exchange.
2. Next Steps — wrap the Signal client in a Swift-friendly API module; design a simple service manager to handle connect/disconnect, retries, and error states; write unit tests for handshake, transient network loss, and message integrity.

**3 UI Integration for P2P**

1. SwiftUI Migration — audit existing AppKit views; scaffold SwiftUI equivalents; use Combine or async/await to bind client state (scanning, connecting, transferring).
2. Key Screens — Discover Peers (live list with connection status and "Refresh" control); Send File (drag-and-drop area, progress bar, cancel button); Receive File (QR-scanner view + fallback manual code entry); Menu Bar Status (icon reflecting online/offline/transfer states).
3. Error & Edge UI — show inline alerts for failed transfers; offline placeholder with "Retry" action.

**4 UX Redesign (Phase 1)**

1. User Flows — map end-to-end "Send" and "Receive" journeys in Miro or Figma.
2. Wireframes — low-fi layouts for each flow step—focus on clarity and ease.
3. High-Fi Mockups — apply branding, spacing, typography (Inter), and native macOS affordances.
4. Prototype & Test — build clickable Figma prototype; test with 3–5 users; gather actionable feedback on discoverability, button labels, and error handling.

**5 Web Server & Download Page**

1. Tech Stack Decision — Option A: Swift/Vapor (single-language). Option B: Node.js/Express (rapid prototyping).
2. MVP Endpoint — `GET /download/:fileID` serves a branded HTML page with "Download" CTA; dynamically fetch file metadata (name, size) before transfer.
3. Client-Server Integration — on "Share," app uploads encrypted blob + metadata to server; returns public link; copy link automatically to clipboard with "Share" confirmation.
4. Deployment — host on Heroku, Render, or small VPS for MVP; set up HTTPS (Let's Encrypt) and CORS for file fetch.

**6 Phase 2 Feature Roadmap**

Trusted-peer management & "Favorites"; background transfer & resume support; in-app chat/messages alongside file metadata; user profiles & avatars (optional accounts); auto-update via Sparkle or native updater.

**7 Testing, QA & Deployment**

1. Automated Tests — unit tests for Signal client and service manager; UI tests for SwiftUI flows (XCTest + XCUITest).
2. CI/CD Pipeline — GitHub Actions: run SwiftLint, tests, and build on each push.
3. Manual QA Checklist — encryption handshake succeeds in local LAN & over internet; file integrity verified (checksum) post-transfer; web download link works in Chrome, Safari, Firefox; dark mode, light mode visuals are consistent.
4. Release — build and notarize .app; distribute via direct download and optionally the Mac App Store.

**8 Workflow Rules for ChatGPT**

Interactive Mode — end each reply with a clear next-step question (e.g. "Ready to review the Send File screen mockups?").
Asset Tracker — maintain a live list of required deliverables (icons, mockups, server config) and mark as done.
Version Control — save major drafts with date stamps; summarize diffs since last iteration.
Source Tagging — when suggesting design inspo, reference only 2–3 P2P or macOS apps (e.g., AirDrop, Snapdrop, Resilio Sync).
Iteration Pace — chunk tasks: draft → review → refine. Avoid overwhelming info dumps.

**Inspiration Shortlist**

| Type | App | Why |
|---|---|---|
| P2P Sharing | AirDrop | Native feel, zero-config ease |
| Web P2P | Snapdrop | HTML-based peer discovery |
| Sync Tool | Resilio Sync | Granular control, seamless background transfers |

(Feel free to swap or add references as we iterate.)

Use this as your single source of truth. Let's build SendLoop into the gold-standard macOS P2P file-sharing app.
