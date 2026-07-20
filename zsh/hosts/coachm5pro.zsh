# bob (nvim manager)
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# coast
export PATH="$HOME/.coast/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"


# android
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"


# sdkman (java)
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
