# =============================================================================
#  hosts/asahim1.zsh — config specific to the Asahi Linux box (Apple Silicon).
#  Sourced from ~/.zshrc when device_name() resolves to "asahim1".
#
#  NOT ACTIVE YET. To enable on that machine:
#    1. run `get_device_id` there and copy the hash
#    2. add it to device_name() in ../zshenv:   <hash>) printf asahim1 ;;
#  Then adjust the nvim version/arch below to match what's installed.
# =============================================================================

# --- device-specific PATHs (typeset -U keeps PATH deduped) -------------------
[[ -d "$RELEASES/nvim/nvim-linux-arm64-10.4/bin" ]] && path=("$RELEASES/nvim/nvim-linux-arm64-10.4/bin" $path)
[[ -d "$RELEASES/opam" ]]                           && path=("$RELEASES/opam" $path)

# --- personal (uncomment / copy from hosts/macm1.zsh if you want them here) --
# alias docfr="mkdir -p \$HOME/Documents/France/ && cd \$HOME/Documents/France/ && rclone sync GoogleDrive:France . --progress && yazi"
# alias rjenkins="cd ~/Music/Ambient\ Techno\ -\ Rob\ Jenkins && yt-dlp -S abr -f ba"
