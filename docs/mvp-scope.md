# LinkaBoo MVP Scope

## In Scope

- macOS sender flow from drag/drop and Finder-adjacent entry points
- native receiver flow from link handoff or manual code entry
- secure link creation
- sender presence and approval states
- direct encrypted file and folder transfer
- progress, cancel, failure, retry, completion
- branded install/status web page
- minimal coordination backend contract

## Out Of Scope

- browser transfer client
- cloud storage
- async delivery
- TURN or relay fallback
- payload proxying
- mandatory accounts
- iOS launch support
- cross-platform parity
- hosted-download expectations

## Acceptance Bar

- both sides can complete a native transfer
- the browser page only hands off
- the backend stores no file data
- failure states are visible and actionable
- product copy stays honest about sender availability
