Folds every multi-line block comment in the current buffer.
It prefers Tree-sitter comment captures and falls back to block comment delimiters.

## Walkthrough

- Open a source file that contains multi-line block comments.
- Run `:FoldBlockComments`.
- The command clears existing manual folds, creates folds for detected block comments,
  and reports how many it folded.

## Tech explanation

`FoldBlockComments` sets the current window's `foldmethod` to `manual`, then runs
`zE` to clear existing manual folds before creating new ones.

The preferred path uses `vim.treesitter.get_parser(0)` and the active language's
`highlights` query. Every capture named `comment` is inspected, and only captures
spanning more than one line are kept as fold ranges.

If Tree-sitter cannot find any foldable comments, the fallback tries to derive
delimiters from `commentstring`. When that is not enough, it uses a small filetype
map for common block comment syntaxes such as `/* */`, `--[[ ]]`, `{- -}`, and
`(* *)`.

All collected ranges are sorted and merged when they overlap or touch. Each final
range is folded with a line-range `:fold` command, and the command finishes with
a `vim.notify` count.
