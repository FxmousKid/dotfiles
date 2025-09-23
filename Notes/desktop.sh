#!/usr/bin/env bash

# This is a scrpit to set up my "desktop wherever i work

set -euo pipefail
IFS=$'\n\t'
INITIAL_DIR="$(pwd)"


repo() { local url="$1"; local dir="$(basename "$url" .git)"; 
         [ -d "$dir/.git" ] && { git -C "$dir" pull --ff-only; } || git clone --recurse-submodules "$url"; }

# ECOLE42 Files 
create_ecole42() {
	ECOLE42DIR="$INITIAL_DIR/Ecole42"
	mkdir -p "$ECOLE42DIR"
	cd "$ECOLE42DIR"

	#------- 42Cursus
	CURSUS42="$ECOLE42DIR/42Cursus"
	mkdir -p "$CURSUS42"
	cd "$CURSUS42"

	repo https://github.com/FxmousKid/42Cursus-Born2BeRoot.git
	repo https://github.com/FxmousKid/42Cursus-CPPs.git
	repo https://github.com/FxmousKid/42Cursus-FdF.git
	repo https://github.com/FxmousKid/42Cursus-ft_irc.git
	repo https://github.com/FxmousKid/42Cursus-ft_printf.git
	repo https://github.com/FxmousKid/42Cursus-ft_transcendence.git
	repo https://github.com/FxmousKid/42Cursus-GetNextLine.git
	repo https://github.com/FxmousKid/42Cursus-Inception.git
	repo https://github.com/FxmousKid/42Cursus-libft.git
	repo https://github.com/FxmousKid/42Cursus-minishell.git
	repo https://github.com/FxmousKid/42Cursus-NetPractice.git
	repo https://github.com/FxmousKid/42Cursus-Philosophers.git
	repo https://github.com/FxmousKid/42Cursus-Pipex.git
	repo https://github.com/FxmousKid/42Cursus-Push_swap.git

	#------- 42Advanced
	cd $CURSUS42
	ADVANCED42="$ECOLE42DIR/42Advanced"
	mkdir -p "$ADVANCED42"
	cd "$ADVANCED42"

	repo https://github.com/FxmousKid/42Advanced-ft_ping.git
	repo https://github.com/FxmousKid/42Advanced-libasm.git

	#------- 42Picine
	cd "$CURSUS42"
	PICINE42="$ECOLE42DIR/42Picine"
	mkdir -p "$PICINE42"
	cd "$PICINE42"

	repo https://github.com/FxmousKid/42Piscine.git
	repo https://github.com/Fxmouskid/42Piscine-Cybersecurity.git
	repo https://github.com/FxmousKid/42Cursus-PiscineReloaded.git

	#------- 42 Tools
	cd "$CURSUS42"
	TOOLS42="$ECOLE42DIR/Tools"
	mkdir -p "$TOOLS42"

	cd "$INITIAL_DIR"
}

create_leetcode() {
	cd "$INITIAL_DIR"
	repo https://github.com/FxmousKid/LeetCode.git
	cd "$INITIAL_DIR"
}

create_aoc() {
	cd "$INITIAL_DIR"
	repo https://github.com/FxmousKid/AdventOfCode.git
	cd "$INITIAL_DIR"
}

create_universite() {
	cd "$INITIAL_DIR"
	repo https://github.com/FxmousKid/Universite.git
	cd "$INITIAL_DIR"
}
