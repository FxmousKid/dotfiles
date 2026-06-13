# =============================================================================
#  hosts/macm1.zsh — config specific to this MacBook (Apple Silicon).
#  Sourced from ~/.zshrc when device_name() resolves to "macm1".
#  Both exports and aliases are fine here (interactive shells only).
# =============================================================================

# --- device-specific PATHs (version-pinned; typeset -U keeps PATH deduped) ---
[[ -d "$RELEASES/nvim-macos-arm64-10.4/bin" ]] && path=("$RELEASES/nvim-macos-arm64-10.4/bin" $path)
[[ -d "$HOME/.antigravity/antigravity/bin" ]]  && path=("$HOME/.antigravity/antigravity/bin" $path)

# --- ESP-IDF (ESP32 devkit) — bump the version to match what's installed -----
alias sidf="source \"\$HOME/.espressif/tools/activate_idf_v5.5.2.sh\""

# --- personal ----------------------------------------------------------------
alias visualiser="\$HOME/Desktop/Ecole42/42Cursus/Tools/push_swap_visualizer/build/bin/visualizer && rm imgui.ini"
alias trsh="alias prev=\"cd \$PWD\" && cd \"\$HOME/.local/share/Trash/files\""
alias rjenkins="cd ~/Music/Ambient\ Techno\ -\ Rob\ Jenkins && yt-dlp -S abr -f ba"
alias docfr="mkdir -p \$HOME/Documents/France/ && cd \$HOME/Documents/France/ && rclone sync GoogleDrive:France . --progress && yazi"
