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
  <a href="install/README.md"><img alt="install" src="https://img.shields.io/badge/install-FF6E33?style=for-the-badge&logo=homebrew&logoColor=white"></a>
  <a href="Notes/README.md"><img alt="Notes" src="https://img.shields.io/badge/Notes-083FA6?style=for-the-badge&logo=markdown&logoColor=white"></a>
</p>

<h3 align="center">Shell &amp; editor</h3>
<p align="center">
  <a href="zsh/README.md"><img alt="zsh" src="https://img.shields.io/badge/zsh-5E60CE?style=for-the-badge&logo=zsh&logoColor=white"></a>
  <a href="bash/README.md"><img alt="bash" src="https://img.shields.io/badge/bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white"></a>
  <a href="lvim/"><img alt="lvim" src="https://img.shields.io/badge/lvim-57A143?style=for-the-badge&logo=neovim&logoColor=white"></a>
  <a href="nvim/README.md"><img alt="nvim" src="https://img.shields.io/badge/nvim-57A143?style=for-the-badge&logo=neovim&logoColor=white"></a>
  <a href="bob/README.md"><img alt="bob" src="https://img.shields.io/badge/bob-6A4C93?style=for-the-badge"></a>
</p>

<h3 align="center">Terminal &amp; multiplexers</h3>
<p align="center">
  <a href="alacritty/README.md"><img alt="alacritty" src="https://img.shields.io/badge/alacritty-F46D01?style=for-the-badge&logo=alacritty&logoColor=white"></a>
  <a href="tmux/README.md"><img alt="tmux" src="https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white"></a>
  <a href="zellij/README.md"><img alt="zellij" src="https://img.shields.io/badge/zellij-9D4EDD?style=for-the-badge"></a>
</p>

<h3 align="center">Tools</h3>
<p align="center">
  <a href="atuin/README.md"><img alt="atuin" src="https://img.shields.io/badge/atuin-0F8B8D?style=for-the-badge"></a>
  <a href="yazi/README.md"><img alt="yazi" src="https://img.shields.io/badge/yazi-7B2CBF?style=for-the-badge"></a>
  <a href="lazygit/README.md"><img alt="lazygit" src="https://img.shields.io/badge/lazygit-F05133?style=for-the-badge&logo=git&logoColor=white"></a>
  <a href="fastfetch/README.md"><img alt="fastfetch" src="https://img.shields.io/badge/fastfetch-33A1FF?style=for-the-badge"></a>
  <a href="ssh/README.md"><img alt="ssh" src="https://img.shields.io/badge/ssh-4D4D4D?style=for-the-badge"></a>
</p>

<h3 align="center">Desktop &amp; keyboard</h3>
<p align="center">
  <a href="karabiner/README.md"><img alt="karabiner (macOS)" src="https://img.shields.io/badge/karabiner-000000?style=for-the-badge&logo=apple&logoColor=white"></a>
  <a href="hyprland/README.md"><img alt="hyprland (Linux)" src="https://img.shields.io/badge/hyprland-58E1FF?style=for-the-badge&logoColor=white"></a>
  <a href="gnome/README.md"><img alt="gnome (Linux)" src="https://img.shields.io/badge/gnome-4A86CF?style=for-the-badge&logo=gnome&logoColor=white"></a>
  <a href="Xmodmap/README.md"><img alt="Xmodmap (Linux)" src="https://img.shields.io/badge/Xmodmap-5A5A5A?style=for-the-badge"></a>
  <a href="halloy/"><img alt="halloy" src="https://img.shields.io/badge/halloy-8338EC?style=for-the-badge"></a>
</p>

---

## How it fits together

- **[install/](install/README.md)** — two small scripts: one links the configs,
  one installs the CLI tools. Both menu-driven and safe to re-run.
- **[zsh/](zsh/README.md)** — the shell setup: load order, PATH, and per-machine
  config via `hosts/`.
- Every other folder has its own README with the details.

## Good to know

- Adding a new machine is one line + one file — see [zsh/ → add a machine](zsh/README.md#add-a-machine).
- The installer skips `ssh/config` (differs per machine) and `~/.gitconfig`
  (not in the repo yet).
