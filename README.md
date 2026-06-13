<h1 align="center">🗂️ dotfiles</h1>

<p align="center">macOS + Fedora Asahi · zsh-first · one command to set up a machine</p>

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white">
  <img alt="Fedora Asahi" src="https://img.shields.io/badge/Fedora%20Asahi-51A2DA?style=for-the-badge&logo=fedora&logoColor=white">
  <img alt="zsh" src="https://img.shields.io/badge/shell-zsh-5E60CE?style=for-the-badge&logo=zsh&logoColor=white">
</p>

---

## Quick start

```sh
git clone <repo> ~/.dotfiles
cd ~/.dotfiles
./install/install.sh
```

Pick what you want from the menu; it links the configs and then offers to
install the tools too. On a fresh machine you only need `sh`, `git`, and `curl`.
Details in **[install/](install/README.md)**.

---

## Map

Tap a tile to open that folder's README.

<h3 align="center">Setup</h3>
<p align="center">
  <a href="install/README.md" title="install"><img alt="install" width="88" src="assets/icons/install.svg"></a>
  <a href="Notes/README.md" title="Notes"><img alt="notes" width="88" src="assets/icons/notes.svg"></a>
</p>

<h3 align="center">Shell &amp; editor</h3>
<p align="center">
  <a href="zsh/README.md" title="zsh"><img alt="zsh" width="88" src="assets/icons/zsh.svg"></a>
  <a href="bash/README.md" title="bash"><img alt="bash" width="88" src="assets/icons/bash.svg"></a>
  <a href="lvim/" title="lvim"><img alt="lvim" width="88" src="assets/icons/lvim.svg"></a>
  <a href="nvim/README.md" title="nvim"><img alt="nvim" width="88" src="assets/icons/nvim.svg"></a>
  <a href="bob/README.md" title="bob"><img alt="bob" width="88" src="assets/icons/bob.svg"></a>
</p>

<h3 align="center">Terminal &amp; multiplexers</h3>
<p align="center">
  <a href="alacritty/README.md" title="alacritty"><img alt="alacritty" width="88" src="assets/icons/alacritty.svg"></a>
  <a href="tmux/README.md" title="tmux"><img alt="tmux" width="88" src="assets/icons/tmux.svg"></a>
  <a href="zellij/README.md" title="zellij"><img alt="zellij" width="88" src="assets/icons/zellij.svg"></a>
</p>

<h3 align="center">Tools</h3>
<p align="center">
  <a href="atuin/README.md" title="atuin"><img alt="atuin" width="88" src="assets/icons/atuin.svg"></a>
  <a href="yazi/README.md" title="yazi"><img alt="yazi" width="88" src="assets/icons/yazi.svg"></a>
  <a href="lazygit/README.md" title="lazygit"><img alt="lazygit" width="88" src="assets/icons/lazygit.svg"></a>
  <a href="fastfetch/README.md" title="fastfetch"><img alt="fastfetch" width="88" src="assets/icons/fastfetch.svg"></a>
  <a href="ssh/README.md" title="ssh"><img alt="ssh" width="88" src="assets/icons/ssh.svg"></a>
</p>

<h3 align="center">Desktop &amp; keyboard</h3>
<p align="center">
  <a href="karabiner/README.md" title="karabiner (macOS)"><img alt="karabiner" width="88" src="assets/icons/karabiner.svg"></a>
  <a href="hyprland/README.md" title="hyprland (Linux)"><img alt="hyprland" width="88" src="assets/icons/hyprland.svg"></a>
  <a href="gnome/README.md" title="gnome (Linux)"><img alt="gnome" width="88" src="assets/icons/gnome.svg"></a>
  <a href="Xmodmap/README.md" title="Xmodmap (Linux)"><img alt="xmodmap" width="88" src="assets/icons/xmodmap.svg"></a>
  <a href="halloy/" title="halloy"><img alt="halloy" width="88" src="assets/icons/halloy.svg"></a>
</p>

---

## How it fits together

- **[install/](install/README.md)** — two small scripts: one links the configs,
  one installs the CLI tools. Both menu-driven and safe to re-run.
- **[zsh/](zsh/README.md)** — the shell setup: load order, PATH, and per-machine
  config via `hosts/`.
- Every other folder has its own README with the details.

Icons are built by [`assets/make-icons.sh`](assets/make-icons.sh) — real logos
from [Simple Icons](https://simpleicons.org) (CC0), monograms for the rest.

## Good to know

- Adding a new machine is one line + one file — see [zsh/ → add a machine](zsh/README.md#add-a-machine).
- The installer skips `ssh/config` (differs per machine) and `~/.gitconfig`
  (not in the repo yet).
