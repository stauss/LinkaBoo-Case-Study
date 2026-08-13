# Transfer Notch Assets

The menu bar icon now supports an expanded transfer notch state while a file transfer is active. I scaffolded two asset catalogs so you can drop in the PNGs that match the design reference.

## Asset folders

Drop files into:

```text
macos/LinkaBooApp/Resources/Assets.xcassets/TransferNotch-Idle.imageset/
macos/LinkaBooApp/Resources/Assets.xcassets/TransferNotch-Progress.imageset/
```

## Expected filenames

### Idle notch

- `transfer-notch-idle.png`
- `transfer-notch-idle@2x.png`
- `transfer-notch-idle@3x.png`

### Expanded progress notch

- `transfer-notch-progress.png`
- `transfer-notch-progress@2x.png`
- `transfer-notch-progress@3x.png`

## Suggested sizing

Because the menu bar view renders at roughly 22pt tall, these are good target exports:

- 1x: 132 × 22 px
- 2x: 264 × 44 px
- 3x: 396 × 66 px

If your final artwork needs slightly different visual bounds, we can adjust the Swift layout to match.

## Current implementation note

Right now the status item is fully scaffolded in Swift using vector drawing for the progress bar and percentage text, so the feature works before the PNGs arrive. These asset sets are ready if you want to swap in more polished bitmap notch backgrounds later.
