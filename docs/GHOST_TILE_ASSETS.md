# Ghost Tile Assets

The floating drag overlay (the Yoink-style ghost that slides in when you start
dragging a file) renders an image asset named `GhostTile`. The asset catalog
entry and `Contents.json` already exist; all you need to do is drop in three
PNG files at the right sizes.

## Files to provide

| Filename              | Size (pixels) | Scale factor |
|-----------------------|---------------|--------------|
| `ghost-tile.png`      | 128 × 128     | @1x          |
| `ghost-tile@2x.png`   | 256 × 256     | @2x          |
| `ghost-tile@3x.png`   | 384 × 384     | @3x          |

- **Format:** PNG with a transparent background.
- **Artwork:** Fill the full square canvas (rounded-corner card + ghost).
- **No baked shadow.** The overlay adds a drop shadow at runtime — if you bake
  one into the PNG it'll double up.
- **No padding.** The image is rendered at a fixed 128pt square, so edge pixels
  that aren't transparent will touch the tile edge.

## Where to put them

Drop all three files into:

```
macos/LinkaBooApp/Resources/Assets.xcassets/GhostTile.imageset/
```

The folder and `Contents.json` already exist — do **not** delete them. The
filenames in `Contents.json` must match the files you drop in exactly.

## Rebuild after installing

From the repo root:

```
task swift:run
```

This regenerates the Xcode project (picks up the new image files) and builds
the app. To verify: launch LinkaBoo, drag any file in Finder, and a ghost tile
should slide in at the bottom-left of your screen.

## Changing the layout

If you want different filenames, scales, or a single 1x PNG instead of 3, edit
`Contents.json` in the same folder. Each entry has `idiom`, `filename`, and
`scale`. The asset name (`GhostTile`) comes from the folder name and is
referenced in Swift as `Image("GhostTile")` inside
`macos/LinkaBooApp/MenuBar/GhostOverlayView.swift`. Rename both sides if you
change it.

## Customising the position at runtime

The floating tile's screen position is user-configurable. Click the LinkaBoo
menu bar icon and pick a location from **Ghost Position** in the bottom menu:

- Bottom, Left of Dock (default)
- Bottom Left / Bottom Right
- Top Left / Top Right
- Left Center / Right Center

The selection persists across launches via `UserDefaults` under the key
`DragOverlayPosition`.
