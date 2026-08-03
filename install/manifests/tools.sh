#!/bin/sh
# shellcheck disable=SC2034  # Values are consumed by the sourcing orchestrator.
# Tool manifest sourced by install/install-tools.sh.
#
# This is the main file to edit when adding a program or changing where it
# comes from. Keep one row per tool and leave unsupported methods empty.
#
# Fields:
#   bin | brew | dnf | copr | apt | gh_repo | custom_fn | eget_filters | eget_file
#
# Resolution order is implemented by install-tools.sh:
#   present -> custom -> brew -> dnf (+ optional COPR) -> apt -> GitHub/eget
#
# Notes:
# - `bin` is the command verified after installation.
# - `copr` is enabled only when DNF is selected for that row.
# - `eget_filters` is a space-separated list of eget --asset filters.
# - `eget_file` selects one executable from an archive with several files.
# - `@bob` is resolved to an exact OS/architecture archive by the orchestrator.
# - Leave apt empty when its package exposes a different command name. Debian's
#   fd-find provides `fdfind`, for example, so fd deliberately uses eget there.

NVIM_DEFAULT='v0.10.4'
DEFAULT_OFF=' glow '
# SDKMAN owns JDK installations on every platform. Keep the distribution and
# exact Java 21 patch level here so changing it remains a one-line edit.
JAVA_SDKMAN_VERSION='21.0.12-tem'
SDKMAN_INSTALL_URL='https://get.sdkman.io?ci=true&rcupdate=false'

TOOLS="
zsh|zsh|zsh||zsh||||
make|make|make||make||||
unzip|unzip|unzip||unzip||||
zip|zip|zip||zip||||
cargo|rust|cargo||cargo||||
clang|llvm|clang||clang||||
clangd|llvm|clang-tools-extra||clangd||||
java||||||install_java||
tmux|tmux|tmux||tmux||||
cscope|cscope|cscope||cscope||||
zellij|zellij|zellij|varlad/zellij||zellij-org/zellij||--asset ^no-web|
yazi|yazi|yazi|lihaohong/yazi||sxyazi/yazi||--asset ^musl|
atuin|atuin|atuin|||atuinsh/atuin||--asset ^musl --asset ^update --asset ^server|
lazygit|lazygit|lazygit|atim/lazygit||jesseduffield/lazygit|||
fastfetch|fastfetch|fastfetch|||fastfetch-cli/fastfetch||--asset ^polyfilled --asset ^.zip|*/usr/bin/fastfetch
eza|eza|eza|||eza-community/eza||--asset ^no_libgit --asset ^.zip|
delta|git-delta|git-delta|||dandavison/delta|||
rg|ripgrep|ripgrep||ripgrep|BurntSushi/ripgrep|||
fd|fd|fd-find|||sharkdp/fd||--asset ^musl|
fzf|fzf|fzf||fzf|junegunn/fzf|||
glow|glow|glow|||charmbracelet/glow|||
tree|tree|tree||tree||||
gh|gh|gh||gh|cli/cli|||
ag|the_silver_searcher|the_silver_searcher||silversearcher-ag||||
bob|||||MordechaiHadad/bob||@bob|
nvim|neovim|neovim||||install_neovim||
nvm||||||install_nvm||
node||||||install_node||
zap||||||install_zap||
lvim||||||install_lvim||
"
