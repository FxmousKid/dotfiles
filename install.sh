#!/usr/bin/env bash

# THIS SCRIPT PREPARES MY SHELL ENVIRONMENT FOR USE
#
# This is to run on a fresh machine, with the following dependencies
#	- zsh
#	- git
#	- curl


txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
bakgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

DOTFILES="$(pwd)"


# Making sure we're in the right branch
if [ ! $(git rev-parse --abbrev-ref HEAD) == "main" ]; then
	echo -e "${txtred}Please switch to the main branch of the dotfiles repo${txtwht}" > /dev/stderr
	exit 1
fi

# First need to source the zshenv for XDG variables
ZSHENV="$DOTFILES/zsh/zshenv"
source "$ZSHENV"

setup_zsh() {

	echo -e "Starting ${txtgrn}zsh${txtwht} dotfiles installation !"


	# 0) Install Zap (zsh plugin manager)
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep

	# 1) Make zsh config
	mkdir -p "$ZDOTDIR"
	ln -sf "$ZSHENV" "$HOME/.zshenv"
	ln -sf "$DOTFILES/zsh/p10k.zsh" "$ZDOTDIR/.p10k.zsh"
	ln -sf "$DOTFILES/zsh/zshrc" "$ZDOTDIR/.zshrc"
}

setup_symlinks() {
	ln -sf "${DOTFILES}/alacritty" "${XDG_CONFIG_HOME}/"
	ln -sf "${DOTFILES}/zellij" "${XDG_CONFIG_HOME}/"
	ln -sf "${DOTFILES}/lvim" "${XDG_CONFIG_HOME}/"
	ln -sf "${DOTFILES}/nvim" "${XDG_CONFIG_HOME}/"
	ln -sf "${DOTFILES}/bob" "${XDG_CONFIG_HOME}/"
}


test() { 
	echo ""
	echo "-------- TESTING --------"
	echo "HOME = $XDG_CONFIG_HOME"
	echo "-------------------------"
}

# option handling
while getopts ":t" opt; do
	case $opt in
		t)
			test
			exit 0
			;;
		/?)
			echo "$0: invalid option -- '$OPTARG'"
			echo "Try '$0 -h' for more information."
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))
