# zellij / plugins

Local Zellij plugin binaries.

## Files

- `zjstatus.wasm` — the status bar plugin.
- `multiview.wasm` — MultiView v0.1.0, a live multi-tab monitoring dashboard.

## Notes

Only vendor plugin binaries here on purpose. If you fetch one elsewhere, note its
source and version.

MultiView source and releases:
<https://github.com/FxmousKid/MultiView>. Its checksum is recorded by the
matching GitHub release and can be verified with `shasum -a 256` on macOS.
The vendored v0.1.0 artifact has SHA-256
`e43f6e9dc22fdd48bc6ceea937832c701c33f6b5dcfc01d8227e3cf44f986ab5`.
