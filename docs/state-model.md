# LinkaBoo State Model

## Share Session

- `draft`
- `staging`
- `manifest_ready`
- `link_ready`
- `waiting_for_recipient`
- `recipient_opened`
- `awaiting_sender`
- `sender_ready`
- `negotiating`
- `transferring`
- `paused`
- `retrying`
- `completed`
- `failed`
- `expired`
- `cancelled`

## Sender UI

- `idle`
- `reviewing_selection`
- `creating_share`
- `waiting`
- `approval_required`
- `connecting`
- `sending`
- `interrupted`
- `complete`
- `failed`

## Receiver UI

- `opening_link`
- `app_required`
- `waiting_for_sender`
- `ready_to_receive`
- `connecting`
- `receiving`
- `save_complete`
- `failed`

## UX Rule

Every failure state should tell the user:

- what happened
- whether it is recoverable
- what to do next
