# ~/.config/fish/config.fish
#

if status is-interactive
    # Commands to run in interactive sessions go here

    alias ls 'ls --color=auto'
    alias grep 'grep --color=auto'

    # Fish doesn't use PS1 — define a prompt function instead
    # Uses fish's built-in $hostname variable instead of the external `hostname` command
    function fish_prompt
    echo -e (whoami)'@'$hostname' '(prompt_pwd -d 0)'\n~> '
end

    #source ~/.config/bash/bashrc  (fish equivalent, if needed, would be its own .fish file)

    alias f 'fastfetch'
# ─────────────────────────────────────────────
# Helper: Warm VFS cache in background
# ─────────────────────────────────────────────
function __warm_drive_cache --argument-names target_dir
    if test -d "$target_dir"
        # Traverses directories asynchronously to populate the dentry cache
        # so SearchEngine.qml / fd results appear immediately
        fd --type d --exclude '$RECYCLE.BIN' --exclude 'System Volume Information' . "$target_dir" >/dev/null 2>&1 &
        disown
    end
end

# ─────────────────────────────────────────────
# Mount Chandan and Study Drive
# ─────────────────────────────────────────────
function mountd --description 'Interactively mount study and/or chandan NTFS drives'
    echo "Which drive would you like to mount?"
    echo "  1) study (/dev/sda1 -> /mnt/study)"
    echo "  2) chandan (/dev/sda2 -> /mnt/chandan)"
    echo "  3) both"
    read -P "Select drive [1-3]: " drive_choice

    echo ""
    echo "How would you like to mount?"
    echo "  1) Read-Only (ro)"
    echo "  2) Read and Write (rw)"
    read -P "Select mode [1-2]: " mode_choice

    set -l uid (id -u)
    set -l gid (id -g)
    set -l mount_opts ""
    set -l mode_label ""

    switch $mode_choice
        case 1
            # User ownership + ro prevents permission errors and ensures zero dirty-bit risk
            set mount_opts "ro,uid=$uid,gid=$gid,fmask=0022,dmask=0022"
            set mode_label "Read-Only"
        case 2
            # windows_names prevents creating filenames invalid in Windows 11
            set mount_opts "rw,uid=$uid,gid=$gid,fmask=0022,dmask=0022,windows_names"
            set mode_label "Read/Write"
        case '*'
            echo "Invalid mode selected. Aborting." >&2
            return 1
    end

    # Ensure mount points exist
    sudo mkdir -p /mnt/study /mnt/chandan

    switch $drive_choice
        case 1
            if sudo mount -t ntfs3 -o $mount_opts /dev/sda1 /mnt/study
                echo "Successfully mounted /mnt/study ($mode_label)"
                __warm_drive_cache /mnt/study
            else
                echo "Failed to mount /mnt/study" >&2
            end

        case 2
            if sudo mount -t ntfs3 -o $mount_opts /dev/sda2 /mnt/chandan
                echo "Successfully mounted /mnt/chandan ($mode_label)"
                __warm_drive_cache /mnt/chandan
            else
                echo "Failed to mount /mnt/chandan" >&2
            end

        case 3
            set -l sda1_status 0
            set -l sda2_status 0

            sudo mount -t ntfs3 -o $mount_opts /dev/sda1 /mnt/study; or set sda1_status 1
            sudo mount -t ntfs3 -o $mount_opts /dev/sda2 /mnt/chandan; or set sda2_status 1

            if test $sda1_status -eq 0 -a $sda2_status -eq 0
                echo "Successfully mounted /mnt/study and /mnt/chandan ($mode_label)"
                __warm_drive_cache /mnt/study
                __warm_drive_cache /mnt/chandan
            else
                echo "One or more mounts failed." >&2
            end

        case '*'
            echo "Invalid drive choice. Aborting." >&2
            return 1
    end
end

# ─────────────────────────────────────────────
# Unmount Chandan and Study Drive
# ─────────────────────────────────────────────
function unmountd --description 'Interactively unmount study and/or chandan NTFS drives'
    echo "Which drive would you like to unmount?"
    echo "  1) study (/mnt/study)"
    echo "  2) chandan (/mnt/chandan)"
    echo "  3) both"
    read -P "Select option [1-3]: " drive_choice

    switch $drive_choice
        case 1
            if sudo umount /mnt/study
                echo "Successfully unmounted /mnt/study"
            else
                echo "Error: Failed to unmount /mnt/study" >&2
                return 1
            end

        case 2
            if sudo umount /mnt/chandan
                echo "Successfully unmounted /mnt/chandan"
            else
                echo "Error: Failed to unmount /mnt/chandan" >&2
                return 1
            end

        case 3
            set -l study_ok 0
            set -l chandan_ok 0

            sudo umount /mnt/study; and set study_ok 1
            sudo umount /mnt/chandan; and set chandan_ok 1

            if test $study_ok -eq 1 -a $chandan_ok -eq 1
                echo "Successfully unmounted both /mnt/study and /mnt/chandan"
            else if test $study_ok -eq 1 -a $chandan_ok -eq 0
                echo "Successfully unmounted /mnt/study, but failed to unmount /mnt/chandan" >&2
                return 1
            else if test $study_ok -eq 0 -a $chandan_ok -eq 1
                echo "Successfully unmounted /mnt/chandan, but failed to unmount /mnt/study" >&2
                return 1
            else
                echo "Error: Failed to unmount both /mnt/study and /mnt/chandan" >&2
                return 1
            end

        case '*'
            echo "Invalid selection. Aborting." >&2
            return 1
    end
end
    # ─────────────────────────────────────────────
    # Monitor input
    # ─────────────────────────────────────────────

    function switch-monitor-to-dp
        ddcutil setvcp 60 15
    end

    alias dp 'switch-monitor-to-dp'

    function switch-monitor-to-hdmi
        ddcutil setvcp 60 17
    end

    alias hdmi 'switch-monitor-to-hdmi'

    # ─────────────────────────────────────────────
    # Pacman
    # ─────────────────────────────────────────────

    alias install 'echo '9988' | sudo -S true && sudo dnf install -y'
    alias update 'echo '9988' | sudo -S true && sudo dnf upgrade --refresh -y'
    alias uninstall 'echo '9988' | sudo -S true && sudo dnf remove -y'

    alias cgpt 'carbonyl https://chatgpt.com/'

    # ─────────────────────────────────────────────
    # Config file shortcuts
    # ─────────────────────────────────────────────

    function _config_file
        switch $argv[1]
            case hyprland-lua hl
                echo "$HOME/.config/hypr/hyprland.lua"
            case waybar-conf
                echo "$HOME/.config/waybar/config"
            case waybar-css
                echo "$HOME/.config/waybar/style.css"
            case docker-css
                echo "$HOME/.config/nwg-dock-hyprland/style.css"
            case drawer-css drc
                echo "$HOME/.config/nwg-drawer/drawer.css"
            case bashrc script
                echo "$HOME/.config/bash/bashrc"
            case '*'
                echo $argv[1]
        end
    end

    # Open with nano
    function nano
        set -l target (_config_file $argv[1])
        command nano $target
    end

    # Open with Kate
    function kate
        set -l target (_config_file $argv[1])
        command kate $target &>/dev/null &
    end

    # Open with Code
    function code
        set -l target (_config_file $argv[1])
        command code $target &>/dev/null &
    end

    # ─────────────────────────────────────────────
    # Search function
    # ─────────────────────────────────────────────

    function search
        if test -z "$argv[1]"
            echo "Usage: search <name>"
            return 1
        end

        find "$HOME" -iname "*$argv[1]*" 2>/dev/null
    end

end
