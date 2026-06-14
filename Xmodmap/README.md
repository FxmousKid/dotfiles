# Xmodmap

X11 keyboard remapping — makes `Super_L` act as Control.

## Files

- `Xmodmap` — clears the Control/Super modifiers, then maps `Super_L` to Control.

## Notes

X11 only; does nothing on Wayland or macOS. Load it with:

```sh
xmodmap ~/.Xmodmap
```
