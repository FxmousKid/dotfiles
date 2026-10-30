# alacritty / scripts

macOS helper that maximizes the focused window to fill its display without going
into native fullscreen. Karabiner runs it (see `karabiner/alacritty.json`).

## Files

- `maximize-windowed` — the shell entry point Karabiner calls. Compiles the Swift
  source on first run and whenever it changes.
- `maximize-windowed.swift` — the Swift source.
- `maximize-windowed.bin` — the compiled binary. Stays at this exact path on
  purpose: macOS grants accessibility permission per executable, so moving it
  means re-approving it in System Settings.

## Usage

```sh
maximize-windowed                 # toggle maximize / restore (what Karabiner calls)
maximize-windowed --maximize      # force maximize
maximize-windowed --restore       # force restore
maximize-windowed --margin 12     # leave a 12pt gap around the window
maximize-windowed --dry-run       # print the decision, change nothing
```

`--margin` also reads `ALACRITTY_MAXIMIZE_MARGIN`. Set
`MAXIMIZE_WINDOWED_DEBUG=1` to log every invocation.

The log lives at `$TMPDIR/alacritty-windowed-maximize.log` and is trimmed once it
passes 256KB. Pre-maximize frames are remembered per window in
`$TMPDIR/alacritty-maximize-windowed.json`.

## Multi-display gotcha

The one thing to get right, and the reason this used to misbehave whenever an
external monitor was plugged in:

- Cocoa (`NSScreen`) measures from the **bottom-left of the primary display**,
  with +y going up.
- The Accessibility API measures from the **top-left of that same primary
  display**, with +y going down.

So the only correct conversion is:

```
axY = NSScreen.screens[0].frame.maxY - cocoaRect.maxY
```

Deriving that offset from the tallest screen instead works only while no display
is taller than the primary. A 1080pt external next to a 982pt laptop panel put
every window 98pt too low — on *both* screens — and made the "which display is
this window on?" test miss, so the window jumped back to the laptop.

`--dry-run` prints the screen it picked and the rect it computed, which is the
fastest way to check this after changing displays.

## Notes

macOS only. Needs accessibility permission and the Xcode command line tools.
Karabiner runs `$HOME/.dotfiles/alacritty/scripts/maximize-windowed`.
