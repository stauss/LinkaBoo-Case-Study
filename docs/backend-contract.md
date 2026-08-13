# LinkaBoo Backend Contract

The backend is a coordination service. It must not store payload bytes.

## Responsibilities

- register installs
- receive sender heartbeats
- create share sessions
- resolve share slugs
- record recipient-open events
- store short-lived negotiation payloads
- expose session status
- expire and cancel sessions

## Non-Responsibilities

- file storage
- file proxying
- browser delivery
- media CDN behavior
- hidden relay fallback
- mandatory account system

## Suggested Entities

### `install`

- `install_id`
- `platform`
- `device_name`
- `app_version`
- `last_seen_at`
- `notifications_enabled`

### `share_session`

- `session_id`
- `sender_install_id`
- `status`
- `created_at`
- `expires_at`
- `item_count`
- `total_bytes`
- `manifest_hash`
- `link_slug`
- `requires_sender_approval`

### `share_item`

- `item_id`
- `session_id`
- `name`
- `mime_type`
- `byte_size`
- `checksum`
- `kind`

### `recipient_request`

- `request_id`
- `session_id`
- `opened_at`
- `receiver_platform`
- `has_app`
- `status`

### `transfer_attempt`

- `attempt_id`
- `session_id`
- `started_at`
- `ended_at`
- `result`
- `failure_reason`

## Suggested Endpoints

- `POST /installs/register`
- `POST /installs/heartbeat`
- `POST /sessions`
- `GET /s/:slug`
- `POST /sessions/:id/recipient-opened`
- `POST /sessions/:id/sender-ready`
- `POST /sessions/:id/cancel`
- `GET /sessions/:id/status`
