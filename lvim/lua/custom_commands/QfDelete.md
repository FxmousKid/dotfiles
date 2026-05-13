Deletes the quickfix item currently under the cursor.
It only works from a quickfix window and rewrites the list after removing that entry.

## Walkthrough

- Open a quickfix list with a command such as `:copen`, `:grep`, or another
  command that populates quickfix entries.
- Move the cursor onto the entry you want to remove.
- Run `:QfDelete`.

## Tech explanation

`QfDelete` first checks the current window with `getwininfo()` and stops if the
window is not a quickfix window.

It reads the current quickfix list with `getqflist()` and uses `line(".")` as the
selected quickfix row. If that row is valid, it removes the matching Lua table
entry with `table.remove`.

The command then replaces the quickfix list through
`setqflist({}, "r", { items = qf, idx = ... })`. The replacement keeps the
remaining items and moves the quickfix index to either the deleted row's position
or the final item when the deleted item was at the end.
