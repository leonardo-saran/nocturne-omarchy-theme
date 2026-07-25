#!/bin/bash
set -e

FORCE=0
for arg in "$@"; do
    case $arg in
        -y|--yes)
            FORCE=1
            shift
            ;;
    esac
done

THEME_NAME="Nocturne"
BACKUP_DIR="$HOME/.config/omarchy/.nocturne-theme-backup"

echo "=== Uninstalling $THEME_NAME ==="

if [ $FORCE -eq 0 ] && [ -t 0 ]; then
    read -p "Do you want to proceed with uninstalling $THEME_NAME? [Y/N] " confirm
    case "$confirm" in
        [Yy]|[Yy][Ee][Ss])
            ;;
        *)
            echo "Uninstallation cancelled."
            exit 0
            ;;
    esac
fi

# Application Detection Phase for Uninstallation
DETECTED_NAMES=()
DETECTED_KEYS=()

# 1. Neovim
if [ -f "$HOME/.config/nvim/colors/nocturne.lua" ]; then
    DETECTED_NAMES+=("Neovim")
    DETECTED_KEYS+=("nvim")
fi

# 2. Zed Editor
if [ -f "$HOME/.config/zed/themes/nocturne-omarchy.json" ]; then
    DETECTED_NAMES+=("Zed Editor")
    DETECTED_KEYS+=("zed")
fi

# 3. VS Code
VSCODE_PATHS=(
    "$HOME/.vscode/extensions/nocturne.nocturne-omarchy-1.0.0"
    "$HOME/.var/app/com.visualstudio.code/data/vscode/extensions/nocturne.nocturne-omarchy-1.0.0"
)
HAS_VSCODE=0
for EXT_DIR in "${VSCODE_PATHS[@]}"; do
    if [ -d "$EXT_DIR" ]; then HAS_VSCODE=1; break; fi
done
if [ $HAS_VSCODE -eq 1 ] || [ -d "$HOME/.config/Code" ]; then
    DETECTED_NAMES+=("VS Code")
    DETECTED_KEYS+=("vscode")
fi

# 4. Ghostty
if [ -f "$HOME/.config/ghostty/themes/nocturne" ]; then
    DETECTED_NAMES+=("Ghostty Terminal")
    DETECTED_KEYS+=("ghostty")
fi

# 5. Kitty
if [ -f "$HOME/.config/kitty/theme.conf" ]; then
    DETECTED_NAMES+=("Kitty Terminal")
    DETECTED_KEYS+=("kitty")
fi

# 6. Alacritty
if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
    DETECTED_NAMES+=("Alacritty Terminal")
    DETECTED_KEYS+=("alacritty")
fi

# 7. Foot
if [ -f "$HOME/.config/foot/foot.ini" ]; then
    DETECTED_NAMES+=("Foot Terminal")
    DETECTED_KEYS+=("foot")
fi

# 8. GTK
if [ -f "$HOME/.config/gtk-3.0/gtk.css" ]; then
    DETECTED_NAMES+=("GTK Theme")
    DETECTED_KEYS+=("gtk")
fi

# 9. Firefox
FF_DIRS=("$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/data/mozilla/firefox" "$HOME/snap/firefox/common/.mozilla/firefox")
FF_PROFILES=()
for ff_dir in "${FF_DIRS[@]}"; do
    if [ -d "$ff_dir" ]; then
        while IFS= read -r -d '' pref_file; do
            p_dir="$(dirname "$pref_file")"
            FF_PROFILES+=("$p_dir")
        done < <(find "$ff_dir" -name "prefs.js" -print0 2>/dev/null)
    fi
done
if [ ${#FF_PROFILES[@]} -gt 0 ]; then
    DETECTED_NAMES+=("Firefox")
    DETECTED_KEYS+=("firefox")
fi

# 10. Chromium
if [ -d "$HOME/.config/chromium" ]; then
    DETECTED_NAMES+=("Chromium")
    DETECTED_KEYS+=("chromium")
fi

NUM_DETECTED=${#DETECTED_NAMES[@]}
if [ "$NUM_DETECTED" -eq 0 ]; then
    echo "No installed $THEME_NAME components detected."
    rm -rf "$HOME/.config/omarchy/themes/nocturne" "$HOME/.config/omarchy/themes/nocturne-omarchy" "$HOME/.config/omarchy/themes/minimal-omarchy" 2>/dev/null || true
    exit 0
fi

# Interactive TUI Menu Selector for Uninstallation
SELECTED_FLAGS=()
for ((i=0; i<NUM_DETECTED; i++)); do
    SELECTED_FLAGS+=(1)
done

if [ $FORCE -eq 0 ] && [ -t 0 ]; then
    CURSOR=0
    REDRAW=0
    TOTAL_MENU_LINES=$((NUM_DETECTED + 2))

    tput civis 2>/dev/null || true
    cleanup_tui() {
        tput cnorm 2>/dev/null || true
    }
    trap cleanup_tui EXIT INT TERM

    draw_menu() {
        if [ "$REDRAW" -eq 1 ]; then
            printf "\033[%dA" "$TOTAL_MENU_LINES" 2>/dev/null || true
        fi
        REDRAW=1

        echo -e "\033[1;36mSelect installed applications to remove $THEME_NAME theme:\033[0m\033[K"
        for i in "${!DETECTED_NAMES[@]}"; do
            chk="[ ]"
            if [ "${SELECTED_FLAGS[$i]}" -eq 1 ]; then
                chk="\033[1;31m[X]\033[0m"
            fi
            
            if [ "$i" -eq "$CURSOR" ]; then
                echo -e " \033[1;33m>\033[0m $chk \033[1;7m ${DETECTED_NAMES[$i]} \033[0m\033[K"
            else
                echo -e "   $chk  ${DETECTED_NAMES[$i]}\033[K"
            fi
        done
        echo -e "\033[90mControls: [↑/↓] Navigate  [Space] Toggle  [a] Toggle All  [Enter] Confirm  [q] Quit\033[0m\033[K"
    }

    draw_menu
    while true; do
        IFS= read -rsn1 key 2>/dev/null || true
        if [ "$key" == $'\x1b' ]; then
            read -rsn2 key 2>/dev/null || true
            if [ "$key" == "[A" ]; then # Up
                CURSOR=$(( (CURSOR - 1 + NUM_DETECTED) % NUM_DETECTED ))
            elif [ "$key" == "[B" ]; then # Down
                CURSOR=$(( (CURSOR + 1) % NUM_DETECTED ))
            fi
        elif [ "$key" == " " ]; then # Space toggle
            SELECTED_FLAGS[$CURSOR]=$(( 1 - SELECTED_FLAGS[$CURSOR] ))
        elif [ "$key" == "a" ] || [ "$key" == "A" ]; then # Toggle all
            ALL_ON=1
            for sf in "${SELECTED_FLAGS[@]}"; do
                if [ "$sf" -eq 0 ]; then ALL_ON=0; break; fi
            done
            NEW_VAL=$(( 1 - ALL_ON ))
            for i in "${!SELECTED_FLAGS[@]}"; do
                SELECTED_FLAGS[$i]=$NEW_VAL
            done
        elif [ "$key" == "" ] || [ "$key" == $'\n' ]; then # Enter confirm
            echo ""
            break
        elif [ "$key" == "q" ] || [ "$key" == "Q" ]; then # Quit
            echo -e "\nUninstallation cancelled."
            exit 0
        fi
        draw_menu
    done
    cleanup_tui
fi

is_selected() {
    local target_key="$1"
    for i in "${!DETECTED_KEYS[@]}"; do
        if [ "${DETECTED_KEYS[$i]}" == "$target_key" ]; then
            if [ "${SELECTED_FLAGS[$i]}" -eq 1 ]; then
                return 0
            else
                return 1
            fi
        fi
    done
    return 1
}

echo "Removing $THEME_NAME from selected applications..."

# 1. Neovim
if is_selected "nvim"; then
    rm -f "$HOME/.config/nvim/colors/nocturne.lua"
    [ -f "$BACKUP_DIR/neovim-nocturne.lua" ] && cp "$BACKUP_DIR/neovim-nocturne.lua" "$HOME/.config/nvim/colors/nocturne.lua"
    echo " -> Removed theme from Neovim."
fi

# 2. Zed Editor
if is_selected "zed"; then
    rm -f "$HOME/.config/zed/themes/nocturne-omarchy.json"
    [ -f "$BACKUP_DIR/zed-nocturne-omarchy.json" ] && cp "$BACKUP_DIR/zed-nocturne-omarchy.json" "$HOME/.config/zed/themes/nocturne-omarchy.json"
    echo " -> Removed theme from Zed Editor."
fi

# 3. VS Code
if is_selected "vscode"; then
    for EXT_DIR in "${VSCODE_PATHS[@]}"; do
        if [ -d "$EXT_DIR" ]; then
            rm -rf "$EXT_DIR"
            echo " -> Removed local extension from VS Code ($EXT_DIR)."
        fi
    done
    python3 -c "
import json, os, re
paths = [
    '~/.config/Code/User/settings.json',
    '~/.config/Code - OSS/User/settings.json',
    '~/.config/Code - Insiders/User/settings.json'
]
for p in paths:
    path = os.path.expanduser(p)
    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
                content = re.sub(r'//.*', '', content)
                content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
                content = re.sub(r',\s*([}\]])', r'\1', content)
                data = json.loads(content)
            data['workbench.colorTheme'] = 'Tokyo Night'
            with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=2)
        except: pass
" 2>/dev/null || true
fi

# 4. Ghostty
if is_selected "ghostty"; then
    rm -f "$HOME/.config/ghostty/themes/nocturne"
    [ -f "$HOME/.config/ghostty/themes/nocturne" ] && cp "$BACKUP_DIR/ghostty-nocturne" "$HOME/.config/ghostty/themes/nocturne"
    echo " -> Removed theme from Ghostty Terminal."
fi

# 5. Kitty
if is_selected "kitty"; then
    rm -f "$HOME/.config/kitty/theme.conf"
    [ -f "$BACKUP_DIR/kitty-theme.conf" ] && cp "$BACKUP_DIR/kitty-theme.conf" "$HOME/.config/kitty/theme.conf"
    echo " -> Removed theme from Kitty Terminal."
fi

# 6. Alacritty
if is_selected "alacritty"; then
    [ -f "$BACKUP_DIR/alacritty.toml" ] && cp "$BACKUP_DIR/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    echo " -> Restored Alacritty Terminal backup."
fi

# 7. Foot
if is_selected "foot"; then
    [ -f "$BACKUP_DIR/foot.ini" ] && cp "$BACKUP_DIR/foot.ini" "$HOME/.config/foot/foot.ini"
    echo " -> Restored Foot Terminal backup."
fi

# 8. GTK
if is_selected "gtk"; then
    if [ -f "$BACKUP_DIR/gtk-3.0-gtk.css" ]; then
        cp "$BACKUP_DIR/gtk-3.0-gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    else
        rm -f "$HOME/.config/gtk-3.0/gtk.css"
    fi

    if [ -f "$BACKUP_DIR/gtk-4.0-gtk.css" ]; then
        cp "$BACKUP_DIR/gtk-4.0-gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    else
        rm -f "$HOME/.config/gtk-4.0/gtk.css"
    fi

    if command -v omarchy-theme-set-gnome &>/dev/null; then
        omarchy-theme-set-gnome 2>/dev/null || true
    fi
    echo " -> Restored GTK backup."
fi

# 9. Firefox
if is_selected "firefox"; then
    for PROFILE in "${FF_PROFILES[@]}"; do
        BACKUP_FILE="$BACKUP_DIR/firefox-userChrome-$(basename "$PROFILE").css"
        if [ -f "$BACKUP_FILE" ]; then
            cp "$BACKUP_FILE" "$PROFILE/chrome/userChrome.css"
        else
            rm -f "$PROFILE/chrome/userChrome.css"
        fi
        echo " -> Removed theme from Firefox profile $(basename "$PROFILE")"
    done
fi

# 10. Chromium
if is_selected "chromium"; then
    CHROMIUM_CONFIG_DIR="$HOME/.config/chromium/Default/User StyleSheets"
    [ -f "$BACKUP_DIR/chromium-Custom.css" ] && cp "$BACKUP_DIR/chromium-Custom.css" "$CHROMIUM_CONFIG_DIR/Custom.css"
    echo " -> Restored Chromium backup."
fi

# Remove theme directories
rm -rf "$HOME/.config/omarchy/themes/nocturne" "$HOME/.config/omarchy/themes/nocturne-omarchy" "$HOME/.config/omarchy/themes/minimal-omarchy" 2>/dev/null || true

# Revert Omarchy system theme to Tokyo Night
if command -v omarchy-theme-set &>/dev/null; then
    omarchy-theme-set "tokyo-night" 2>/dev/null || true
elif command -v omarchy &>/dev/null; then
    omarchy theme set "tokyo-night" 2>/dev/null || true
fi

echo "=== $THEME_NAME uninstallation complete! ==="
