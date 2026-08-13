# LinkaBoo MVP Outline

## Version

* Date: 2026-04-11
* Status: Draft v1

## Product Summary

LinkaBoo is a native macOS file-sharing app focused on fast, delightful, encrypted sharing with a lightweight drag-and-drop experience. The MVP should feel closer to a magical handoff tool than a file manager.

The core experience is:

1. Drag a file or folder
2. Drop it onto the LinkaBoo target
3. Prepare a secure share
4. Deliver directly when possible
5. Fall back gracefully when direct delivery is not possible
6. Keep the sender informed with simple, friendly status states

## MVP Goals

* Deliver a polished macOS-first sharing experience
* Support secure sharing of files and folders
* Prioritize peer-to-peer transfer when possible
* Preserve a simple UX with minimal account friction
* Make the product feel fast, clear, and trustworthy
* Establish a strong foundation for future identity, peer discovery, and web fallback features

## What the MVP Is

* A native macOS sharing utility
* Drag-and-drop first
* End-to-end encrypted transport
* P2P-preferred architecture
* Lightweight transfer activity tracking
* Menu bar or lightweight app presence

## What the MVP Is Not

* A cloud storage product
* A long-term file library
* A full collaboration suite
* A heavy account-based platform
* A full trusted-peer system yet

## Core User Story

As a macOS user, I want to drag a file or folder onto LinkaBoo, create a secure share quickly, and send it with as little setup as possible.

## Primary MVP Flow

### 1. Idle State

* LinkaBoo is available from the Dock, menu bar, or lightweight app presence
* The product is visible enough to be discovered, but not intrusive

### 2. Drag Start

* User begins dragging a file or folder from Finder or desktop
* LinkaBoo presents a visible drop target or active state

### 3. Active Drop Target

* Boo or the LinkaBoo widget highlights to show it is ready to receive the item
* The interaction must feel obvious and responsive

### 4. Drop to Share

* User drops the file or folder onto the target
* LinkaBoo opens the share initiation UI

### 5. Share Initiation

For MVP, the app should support the leanest possible send flow:

* Prepare secure share
* Optionally allow recipient entry later if implemented
* Always support generating a shareable secure link/session

Recommended MVP direction:

* Do not make email identity mandatory
* Keep recipient targeting optional unless identity lookup is already implemented

### 6. Transfer Preparation

* App validates the file/folder
* App prepares encrypted transfer metadata
* App attempts direct delivery when possible
* App can fall back to relay-assisted or temporary secure delivery if needed

### 7. Progress State

* User sees a clear progress or waiting state
* Status language should remain simple, such as:

  * Preparing secure share
  * Sending directly
  * Waiting for recipient
  * Copying share link

### 8. Success State

* User sees a friendly success confirmation
* Share link is copied to clipboard when applicable
* A toast confirms clipboard behavior

### 9. Activity Tracking

* LinkaBoo shows recent transfer activity, not a permanent file library
* Each item can display:

  * file or folder name
  * recipient or delivery method if known
  * transfer status
  * time sent
  * revocation state if supported

## Required MVP Screens and States

### 1. Idle / Ready State

Purpose:

* Show that LinkaBoo is available and ready

Needs:

* Menu bar or app presence
* Clear brand expression
* Minimal visual noise

### 2. Drag Detection / Drop Target State

Purpose:

* Make drag-to-share discoverable and intuitive

Needs:

* Active hover state
* Strong visual feedback
* Fast animation response

### 3. Share Initiation State

Purpose:

* Let user confirm what is being shared
* Start secure share

Needs:

* Shared item preview
* Primary action to continue
* Optional recipient input if supported
* Cancel action

### 4. Progress / Preparing State

Purpose:

* Communicate that LinkaBoo is working

Needs:

* Progress text
* Lightweight animation
* Cancel where technically possible

### 5. Success State

Purpose:

* Confirm that the share is ready, sent, or available

Needs:

* Positive confirmation
* Clipboard toast when link is copied
* Simple next step

### 6. Recent Activity Screen

Purpose:

* Show what was recently shared and current status

Needs:

* Recent shares list
* Status labels
* Hover actions
* Revoke or cancel only when technically valid

### 7. Receiver State

Purpose:

* Show what happens when a recipient with the app receives a share

Needs:

* Notification or incoming-share alert
* Clear accept/open/download action
* Safe default behavior for save location

### 8. Settings Screen

Purpose:

* Support minimum app configuration for MVP

Needs:

* Launch at login
* Notifications
* Default save location
* Appearance mode behavior if needed
* Encryption or connection status summary
* Basic app info

## Recommended MVP Technical Behavior

### Transfer Model

* Prefer direct peer-to-peer connection
* Use Signal-protocol-backed encryption layer already integrated in the project
* Allow relay-assisted or temporary fallback if direct handoff is unavailable
* Keep the UX consistent even if transport changes behind the scenes

### File Handling

* Support files and folders
* Do not position LinkaBoo as a persistent file repository
* Treat transfers as temporary activity, not imported content

### Clipboard Behavior

* Copy share link automatically only when applicable
* Show a toast confirming link copy
* Avoid implying a link exists when the share is purely direct and no fallback link was created

### Revocation Behavior

Use language that matches actual capability:

* Cancel Share
* Revoke Link
* Stop Availability

Avoid overpromising with "Unshare" if the recipient may already have access to the data.

## MVP Architecture Principles

* Native macOS-first experience
* SwiftUI-friendly UI architecture
* Service manager for connection lifecycle, retries, and errors
* Swift-friendly wrapper around the Signal client
* Clear transfer state model shared by UI and networking layers

## Required MVP State Model

The implementation should define a shared state machine that both design and engineering follow.

Suggested states:

* idle
* dragging
* drop_target_active
* share_initiated
* validating_item
* preparing_secure_share
* attempting_direct_transfer
* relay_fallback
* waiting_for_recipient
* transferring
* success
* cancelled
* failed
* expired
* revoked

## Error States Needed for MVP

* Invalid file or folder
* Unsupported item
* File too large
* Network unavailable
* Direct transfer failed
* Relay fallback unavailable
* Recipient unavailable
* Share creation failed
* Clipboard copy failed
* Permission or access denied

Each error should include:

* clear plain-language explanation
* retry action when possible
* dismiss action

## Empty States Needed for MVP

* No recent shares yet
* No incoming transfers
* No active transfers

## Security and Trust Requirements

* End-to-end encryption must remain central to product messaging
* Do not weaken perceived trust with overly playful copy in serious states
* Make success, failure, and transfer status explicit
* Do not auto-place incoming files on desktop by default without user control

## Branding Guidance for MVP

* Product name: LinkaBoo
* Domain direction: linka.boo
* Boo mascot can be used as a warm interaction layer
* Boo should support clarity, not distract from security or status

## MVP Deliverables

### Product / UX

* Core flow map
* Finalized state model
* MVP screen set
* Error state designs
* Settings screen design
* Recent activity screen design

### Engineering

* Signal wrapper module
* Service manager for connection lifecycle
* Drag-and-drop entry point
* Transfer state handling
* Clipboard integration
* Activity log model
* Unit tests for transfer and handshake flows

### QA

* File sharing on local network
* File sharing across internet conditions
* Transfer retry handling
* File integrity validation
* Empty, loading, success, and failure states
* Light and dark mode review

## Out of Scope for MVP

* Full contact system
* Robust account graph
* Trusted peers and favorites
* Full web download flow for non-app users
* In-app chat
* Background resume support
* Rich profile system
* Extensive admin controls

## Phase 1.5 / Post-MVP Candidates

* LinkaBoo handle system
* Email-based identity lookup
* Installed-user detection
* Trusted peers
* Web fallback for non-app recipients
* Expiring links and richer revocation controls
* Better transfer history filters

## Open Decisions Still to Finalize

1. Whether recipient entry is in MVP or post-MVP
2. Whether fallback relay is in MVP or introduced immediately after
3. Whether drag detection uses Dock behavior, overlay behavior, or both
4. What the default incoming file save behavior should be
5. How much activity history is visible in the MVP UI

## Recommended Build Order

1. Transfer state model
2. Drag/drop trigger and active target behavior
3. Secure share preparation flow
4. Direct transfer attempt
5. Success/failure states
6. Recent activity screen
7. Settings screen
8. QA and polish

## Asset Tracker

### Done

* Core drag/drop sharing concept
* Active drop state concept
* Share confirmation concept
* Sharing progress concept
* Success concept
* Recent activity concept
* Installed-app receiver concept

### Still Needed

* Settings screen
* Error states
* Empty states
* Receiver accept/download flow
* Revoke/cancel share behavior spec
* Link copied toast spec
* Menu bar status states
* Offline/retry states
* Final transfer state model

## Summary

LinkaBoo MVP should be a focused, macOS-native, drag-and-drop encrypted sharing experience that feels magical but remains technically honest. The product should emphasize quick handoff, strong status clarity, and a lightweight workflow rather than long-term file management.
