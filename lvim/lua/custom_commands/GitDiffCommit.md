Sets a Git base commit and opens quickfix entries for files changed since that commit.
Then `:DiffBase` or `<leader>gd` opens a side-by-side diff against that commit.

## Walkthrough

- Run `:GitSetBase <commit>` from inside a Git repository, for example
  `:GitSetBase main` or `:GitSetBase abc1234`.
- Use the quickfix list to jump through files changed between that commit and `HEAD`.
- Open one of those files, then run `:DiffBase` or press `<leader>gd`.
- The current file stays on the left, and a scratch buffer containing the base
  version opens on the right in diff mode.

## Tech explanation

The module stores the selected commit in the global `_G.git_base_commit`.

`GitSetBase` resolves the repository root with `git rev-parse --show-toplevel`,
runs `git -C <root> diff --name-only <commit> HEAD`, and converts every changed
path into a quickfix item pointing at line 1. It replaces the quickfix list with
those entries and opens it with `:copen`.

`DiffBase` reads the current buffer path, resolves it relative to the Git root,
opens a vertical split, and creates an unlisted scratch buffer for the old version.
It fills that buffer with `git show <commit>:<relative-path>`, marks it
unmodifiable, copies the current filetype, and names it with the relative path
plus a shortened commit hash.

Before enabling the comparison, it runs `diffoff!` in the two participating
windows, then runs `diffthis` in both so only the current file and scratch buffer
are diffed. The cursor is returned to the original file window at the end.
