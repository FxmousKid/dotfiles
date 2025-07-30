#!/usr/bin/env bash

# This is a scrpit to set up my desktop wherever i work

INITIAL_DIR="$(pwd)"

# ECOLE42 Files 
create_ecole42() {
	ECOLE42DIR="$INITIAL_DIR/Ecole42"
	mkdir -p $ECOLE42DIR
	cd $ECOLE42DIR

	#------- 42Cursus
	CURSUS42="$ECOLE42DIR/42Cursus"
	mkdir -p $CURSUS42
	cd $CURSUS42

	git clone --recurse-submodules https://github.com/42Cursus-Born2BeRoot.git
	git clone --recurse-submodules https://github.com/42Cursus-CPPs.git
	git clone --recurse-submodules https://github.com/42Cursus-FdF.git
	git clone --recurse-submodules https://github.com/42Cursus-ft_irc.git
	git clone --recurse-submodules https://github.com/42Cursus-ft_printf.git
	git clone --recurse-submodules https://github.com/42Cursus-ft_transcendence.git
	git clone --recurse-submodules https://github.com/42Cursus-GetNextLine.git
	git clone --recurse-submodules https://github.com/42Cursus-Inception.git
	git clone --recurse-submodules https://github.com/42Cursus-libft.git
	git clone --recurse-submodules https://github.com/42Cursus-minishell.git
	git clone --recurse-submodules https://github.com/42Cursus-NetPractice.git
	git clone --recurse-submodules https://github.com/42Cursus-Philosophers.git
	git clone --recurse-submodules https://github.com/42Cursus-Pipex.git
	git clone --recurse-submodules https://github.com/42Cursus-Push_swap.git

	#------- 42Advanced
	cd $CURSUS42
	ADVANCED42="$ECOLE42DIR/42Advanced"
	mkdir -p $ADVANCED42
	cd $ADVANCED42

	git clone --recurse-submodules https://github.com/42Advanced-ft_ping.git
	git clone --recurse-submodules https://github.com/42Advanced-libasm.git

	#------- 42Picine
	cd $CURSUS42
	PICINE42="$ECOLE42DIR/42Picine"
	mkdir -p $PICINE42
	cd $PICINE42

	git clone --recurse-submodules https://github.com/FxmousKid/42Piscine.git
	git clone --recurse-submodules https://github.com/Fxmouskid/42Piscine-Cybersecurity.gi
	git clone --recurse-submodules https://github.com/FxmousKid/42Cursus-PiscineReloaded.git

	#------- 42 Tools
	cd $CURSUS42
	TOOLS42="$ECOLE42DIR/Tools"
	mkdir -p $TOOLS42

	cd $INITIAL_DIR
}

create_leetcode() {
	cd $INITIAL_DIR
	git clone --recurse-submodules https://github.com/FxmousKid/LeetCode.git
	cd $INITIAL_DIR
}

create_aoc() {
	cd $INITIAL_DIR
	git clone --recurse-submodules https://github.com/FxmousKid/AdventOfCode.git
	cd $INITIAL_DIR
}

create_universite() {
	cd $INITIAL_DIR
	git clone --recurse-submodules https://github.com/FxmousKid/Universite.git
	cd $INITIAL_DIR
}
