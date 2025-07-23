#!/usr/bin/env bash

# THIS SCRIPT PREPARES MY SHELL ENVIRONMENT FOR USE
#
# This is to run on a fresh machine, with the following dependencies
#	- zsh
#	- make
#	- git

DOTFILES="$HOME/.dotfiles"


# Making sure we're in the right branch
if [ ! $(git rev-parse --abbrev-ref HEAD) == "main" ]; then
	echo "Please switch to the main branch" > /dev/stderr
	exit 1
fi


# First need to source the zshenv for XDG variables
ZSHENV="$DOTFILES/zsh/zshenv"
source "$ZSHENV"


# 0) Install Zap (zsh plugin manager)
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep

# 1) Make zsh config
mkdir -p "$ZDOTDIR"
ln -sf "$ZSHENV" "$HOME/.zshenv"
ln -sf "$DOTFILES/zsh/p10k.zsh" "$ZDOTDIR/.p10k.zsh"
ln -sf "$DOTFILES/zsh/zshrc" "$ZDOTDIR/.zshrc"
