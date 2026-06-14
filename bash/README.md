# bash

Bash config — a fallback for machines where zsh isn't set up.

## Files

- `bash_profile` — adds `~/bin` to PATH, sources Cargo and Atuin env if present.
- `bashrc` — sources `/etc/bashrc`, adds local bin dirs to PATH, loads
  `~/.bashrc.d/*`, and starts Atuin and Cargo if installed.
- `bash_logout` — empty placeholder.

## Notes

Everything optional is guarded with existence checks, so these still work on a
machine without Cargo or Atuin.
