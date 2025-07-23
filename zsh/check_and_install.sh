#!/bin/sh

IS_SUDO=0

check_and_install_packages() {
    # Checks if package is installed
    if command -v "$1" > /dev/null 2>&1; then
        return
    fi

    # Check if /etc/os-release exists and sudo hasn't been used yet
    if [ -f /etc/os-release ] && [ "$IS_SUDO" -eq 0 ]; then
        echo "Enter Password to install $1"
        IS_SUDO=1
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            fedora|fedora-asahi-remix)
                sudo dnf install "$1"
                ;;
            arch)
                sudo pacman -S "$1"
                ;;
            debian)
                sudo apt install "$1"
                ;;
            ubuntu)
                echo "Please install $1 in the correct way from their GitHub"
                ;;
            *)
                echo "Your distro ($ID) is not supported for auto-install."
                echo "Please post a PR to the dotfiles repo to support it."
                ;;
        esac
    else
        echo "Unable to read /etc/os-release"
    fi
}

check_and_install_lazygit() {
    if ! command -v lazygit > /dev/null 2>&1; then
        if [ "$IS_SUDO" -eq 1 ]; then
            sudo dnf copr enable atim/lazygit -y
        else
            echo "Please enable the atim/lazygit copr repository"
            sudo dnf copr enable atim/lazygit -y
            IS_SUDO=1
        fi
    fi
    check_and_install_packages "lazygit"
}

check_and_install_zellij() {
    if ! command -v zellij > /dev/null 2>&1; then
        if [ "$IS_SUDO" -eq 1 ]; then
            sudo dnf copr enable varlad/zellij
        else
            echo "Please enable sudo mode to enable the zellij copr repository"
            sudo dnf copr enable varlad/zellij
            IS_SUDO=1
        fi
    fi
    check_and_install_packages "zellij"
    ln -sf "$HOME/.dotfiles/zellij/" "$HOME/.config/zellij"
}

check_and_install_yazi() {
    if ! command -v yazi > /dev/null 2>&1; then
        if [ "$IS_SUDO" -eq 1 ]; then
            sudo dnf copr enable lihaohong/yazi -y
        else
            echo "Please enable the lihaohong/yazi copr repository"
            sudo dnf copr enable lihaohong/yazi -y
            IS_SUDO=1
        fi
    fi
    check_and_install_packages "yazi"
}

check_and_install_atuin() {
    if ! command -v atuin > /dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
        # ln -sf ~/.dotfiles/atuin/config.toml ~/.config/atuin/
    fi
}

check_and_install_zap_zsh() {
    if command -v zap > /dev/null 2>&1; then
        return
    fi
    # Portable POSIX-compatible zsh invocation
    zsh -c "$(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep"
}

move_trash() {
	if [ -d ~/.local/share/Trash ]; then
		mv $1 ~/.local/share/Trash
	fi
}

check_and_install_all_packages() {
    check_and_install_packages "fastfetch"
	move_trash ~/.config/fastfetch/
    ln -sf ~/.dotfiles/fastfetch ~/.config/
    check_and_install_packages "go"
    check_and_install_packages "glow"
    check_and_install_packages "strace"
    check_and_install_packages "ltrace"
    check_and_install_packages "tree"
    check_and_install_packages "alacritty"
	ln -sf ~/.dotfiles/alacritty ~/.config/
    check_and_install_packages "gh"
    check_and_install_packages "git-delta"
	move_trash ~/.gitconfig
	ln -sf ~/.dotfiles/git/gitconfig ~/.gitconfig
    check_and_install_lazygit
    check_and_install_yazi
    check_and_install_zellij
	move_trash ~/.config/zellij
	ln -sf ~/.dotfiles/zellij/ ~/.config/
    check_and_install_atuin
	check_and_install_zap_zsh
}

#--------- Node Version Manager
# Only install NVM if not already installed
if [ ! -d "$NVM_DIR/nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | sh
fi

check_and_install_all_packages
