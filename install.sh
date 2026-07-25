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
THEME_DIR="$HOME/.config/omarchy/themes/nocturne"
BACKUP_DIR="$HOME/.config/omarchy/.nocturne-theme-backup"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing $THEME_NAME ==="

if [ $FORCE -eq 0 ] && [ -t 0 ]; then
    read -p "Do you want to proceed with installing $THEME_NAME? [Y/N] " confirm
    case "$confirm" in
        [Yy]|[Yy][Ee][Ss])
            ;;
        *)
            echo "Installation cancelled."
            exit 0
            ;;
    esac
fi

# Clean legacy theme folder names if present
rm -rf "$HOME/.config/omarchy/themes/nocturne-omarchy" "$HOME/.config/omarchy/themes/minimal-omarchy" 2>/dev/null || true

mkdir -p "$BACKUP_DIR"
mkdir -p "$THEME_DIR"

if [ ! -f "$SCRIPT_DIR/gtk.css" ] && [ ! -f "$THEME_DIR/gtk.css" ]; then
    echo "Downloading $THEME_NAME theme files..."
    TEMP_CLONE="$(mktemp -d)"
    if command -v git &>/dev/null; then
        git clone --depth 1 https://github.com/leonardo-saran/nocturne-omarchy-theme.git "$TEMP_CLONE" 2>/dev/null || true
    else
        curl -sL https://github.com/leonardo-saran/nocturne-omarchy-theme/archive/refs/heads/main.tar.gz | tar -xz -C "$TEMP_CLONE" --strip-components=1 2>/dev/null || true
    fi
    if [ -f "$TEMP_CLONE/gtk.css" ]; then
        cp -r "$TEMP_CLONE/"* "$THEME_DIR/" 2>/dev/null || true
    fi
    rm -rf "$TEMP_CLONE"
fi

if [ -d "$SCRIPT_DIR" ] && [ "$SCRIPT_DIR" != "/dev/fd" ] && [ -f "$SCRIPT_DIR/gtk.css" ]; then
    echo "Syncing theme source files to $THEME_DIR..."
    find "$SCRIPT_DIR" -maxdepth 1 -type f -exec cp {} "$THEME_DIR/" \; 2>/dev/null || true
    [ -d "$SCRIPT_DIR/backgrounds" ] && cp -r "$SCRIPT_DIR/backgrounds" "$THEME_DIR/" 2>/dev/null || true
fi

if command -v omarchy-theme-install &>/dev/null; then
    omarchy-theme-install https://github.com/leonardo-saran/nocturne-omarchy-theme || true
fi

# Application Detection Phase
DETECTED_NAMES=()
DETECTED_KEYS=()

# 1. Neovim
if command -v nvim &>/dev/null; then
    DETECTED_NAMES+=("Neovim")
    DETECTED_KEYS+=("nvim")
fi

# 2. Zed Editor
if command -v zed &>/dev/null || command -v zed-editor &>/dev/null || [ -d "$HOME/.config/zed" ]; then
    DETECTED_NAMES+=("Zed Editor")
    DETECTED_KEYS+=("zed")
fi

# 3. VS Code
if command -v code &>/dev/null || [ -d "$HOME/.vscode" ] || [ -d "$HOME/.config/Code" ]; then
    DETECTED_NAMES+=("VS Code")
    DETECTED_KEYS+=("vscode")
fi

# 4. Ghostty
if command -v ghostty &>/dev/null; then
    DETECTED_NAMES+=("Ghostty Terminal")
    DETECTED_KEYS+=("ghostty")
fi

# 5. Kitty
if command -v kitty &>/dev/null; then
    DETECTED_NAMES+=("Kitty Terminal")
    DETECTED_KEYS+=("kitty")
fi

# 6. Alacritty
if command -v alacritty &>/dev/null; then
    DETECTED_NAMES+=("Alacritty Terminal")
    DETECTED_KEYS+=("alacritty")
fi

# 7. Foot
if command -v foot &>/dev/null; then
    DETECTED_NAMES+=("Foot Terminal")
    DETECTED_KEYS+=("foot")
fi

# 8. GTK
if [ -d "$HOME/.config/gtk-3.0" ] || [ -d "$HOME/.config/gtk-4.0" ]; then
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
if command -v firefox &>/dev/null || [ ${#FF_PROFILES[@]} -gt 0 ]; then
    DETECTED_NAMES+=("Firefox")
    DETECTED_KEYS+=("firefox")
fi

# 10. Chromium
if command -v chromium &>/dev/null || command -v google-chrome &>/dev/null; then
    DETECTED_NAMES+=("Chromium / Chrome")
    DETECTED_KEYS+=("chromium")
fi

NUM_DETECTED=${#DETECTED_NAMES[@]}
if [ "$NUM_DETECTED" -eq 0 ]; then
    echo "No supported applications detected on this system."
    exit 0
fi

# Interactive TUI Menu Selector
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

        echo -e "\033[1;36mSelect target applications to install $THEME_NAME theme:\033[0m\033[K"
        for i in "${!DETECTED_NAMES[@]}"; do
            chk="[ ]"
            if [ "${SELECTED_FLAGS[$i]}" -eq 1 ]; then
                chk="\033[1;32m[X]\033[0m"
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
            echo -e "\nInstallation cancelled."
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

echo "Applying $THEME_NAME to selected applications..."

# 1. Neovim
if is_selected "nvim"; then
    mkdir -p "$HOME/.config/nvim/colors"
    [ -f "$HOME/.config/nvim/colors/nocturne.lua" ] && cp "$HOME/.config/nvim/colors/nocturne.lua" "$BACKUP_DIR/neovim-nocturne.lua"
    if [ -f "$THEME_DIR/neovim.lua" ]; then
        cp "$THEME_DIR/neovim.lua" "$HOME/.config/nvim/colors/nocturne.lua"
    elif [ -f "$SCRIPT_DIR/neovim.lua" ]; then
        cp "$SCRIPT_DIR/neovim.lua" "$HOME/.config/nvim/colors/nocturne.lua"
    fi
    echo " -> Applied theme to Neovim."
fi

# 2. Zed Editor
if is_selected "zed"; then
    mkdir -p "$HOME/.config/zed/themes"
    [ -f "$HOME/.config/zed/themes/nocturne-omarchy.json" ] && cp "$HOME/.config/zed/themes/nocturne-omarchy.json" "$BACKUP_DIR/zed-nocturne-omarchy.json"
    
    SRC_ZED="$SCRIPT_DIR/zed.json"
    [ ! -f "$SRC_ZED" ] && SRC_ZED="$THEME_DIR/zed.json"
    if [ -f "$SRC_ZED" ]; then
        cp "$SRC_ZED" "$HOME/.config/zed/themes/nocturne-omarchy.json"
    fi
    
    python3 -c "
import json, os, re
path = os.path.expanduser('~/.config/zed/settings.json')
data = {}
if os.path.exists(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            content = re.sub(r'//.*', '', content)
            content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
            content = re.sub(r',\s*([}\]])', r'\1', content)
            data = json.loads(content)
    except: pass
data['theme'] = 'Nocturne'
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=2)
" 2>/dev/null || true

    echo " -> Applied and set active theme in Zed Editor."
fi

# 3. VS Code
if is_selected "vscode"; then
    SRC_VSCODE="$SCRIPT_DIR/vscode_colors.json"
    [ ! -f "$SRC_VSCODE" ] && SRC_VSCODE="$THEME_DIR/vscode_colors.json"

    # Strategy 1: Native .vsix packaging & installation via code CLI
    if command -v code &>/dev/null && command -v zip &>/dev/null && [ -f "$SRC_VSCODE" ]; then
        VSIX_TMP="$(mktemp -d)"
        mkdir -p "$VSIX_TMP/extension/themes"
        cat > "$VSIX_TMP/extension/package.json" <<'EOF'
{
  "name": "nocturne-omarchy",
  "displayName": "Nocturne",
  "description": "Nocturne Theme for VS Code",
  "version": "1.0.0",
  "publisher": "nocturne",
  "engines": {
    "vscode": "^1.60.0"
  },
  "categories": [
    "Themes"
  ],
  "contributes": {
    "themes": [
      {
        "label": "Nocturne",
        "uiTheme": "vs-dark",
        "path": "./themes/nocturne-omarchy-color-theme.json"
      }
    ]
  }
}
EOF
        cp "$SRC_VSCODE" "$VSIX_TMP/extension/themes/nocturne-omarchy-color-theme.json"
        (cd "$VSIX_TMP/extension" && zip -r "$VSIX_TMP/nocturne-omarchy.vsix" . >/dev/null 2>&1)
        code --install-extension "$VSIX_TMP/nocturne-omarchy.vsix" --force >/dev/null 2>&1 || true
        rm -rf "$VSIX_TMP"
    fi

    # Strategy 2: Direct extension directory copy & extensions.json manifest registration
    EXT_DIR="$HOME/.vscode/extensions/nocturne.nocturne-omarchy-1.0.0"
    mkdir -p "$EXT_DIR/themes"
    cat > "$EXT_DIR/package.json" <<'EOF'
{
  "name": "nocturne-omarchy",
  "displayName": "Nocturne",
  "description": "Nocturne Theme for VS Code",
  "version": "1.0.0",
  "publisher": "nocturne",
  "engines": {
    "vscode": "^1.60.0"
  },
  "categories": [
    "Themes"
  ],
  "contributes": {
    "themes": [
      {
        "label": "Nocturne",
        "uiTheme": "vs-dark",
        "path": "./themes/nocturne-omarchy-color-theme.json"
      }
    ]
  }
}
EOF
    if [ -f "$SRC_VSCODE" ]; then
        cp "$SRC_VSCODE" "$EXT_DIR/themes/nocturne-omarchy-color-theme.json"
    fi

    python3 -c "
import json, os, re, time
paths = [
    '~/.config/Code/User/settings.json',
    '~/.config/Code - OSS/User/settings.json',
    '~/.config/Code - Insiders/User/settings.json'
]
for p in paths:
    path = os.path.expanduser(p)
    if os.path.exists(os.path.dirname(path)) or os.path.exists(os.path.dirname(os.path.dirname(path))):
        data = {}
        if os.path.exists(path):
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    content = re.sub(r'//.*', '', content)
                    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
                    content = re.sub(r',\s*([}\]])', r'\1', content)
                    data = json.loads(content)
            except: pass
        data['workbench.colorTheme'] = 'Nocturne'
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=2)

ext_file = os.path.expanduser('~/.vscode/extensions/extensions.json')
ext_dir = os.path.expanduser('~/.vscode/extensions/nocturne.nocturne-omarchy-1.0.0')
if os.path.exists(os.path.dirname(ext_file)):
    try:
        ext_list = []
        if os.path.exists(ext_file):
            with open(ext_file, 'r', encoding='utf-8') as f:
                ext_list = json.load(f)
        ext_list = [e for e in ext_list if e.get('identifier', {}).get('id') != 'nocturne.nocturne-omarchy']
        ext_list.append({
            'identifier': {'id': 'nocturne.nocturne-omarchy'},
            'version': '1.0.0',
            'location': {
                '\$mid': 1,
                'fsPath': ext_dir,
                'external': f'file://{ext_dir}',
                'path': ext_dir,
                'scheme': 'file'
            },
            'relativeLocation': 'nocturne.nocturne-omarchy-1.0.0',
            'metadata': {'installedTimestamp': int(time.time() * 1000), 'pinned': False}
        })
        with open(ext_file, 'w', encoding='utf-8') as f: json.dump(ext_list, f, indent=2)
    except: pass
" 2>/dev/null || true

    echo " -> Installed extension and activated theme in VS Code."
fi

# 4. Ghostty
if is_selected "ghostty"; then
    mkdir -p "$HOME/.config/ghostty/themes"
    [ -f "$HOME/.config/ghostty/themes/nocturne" ] && cp "$HOME/.config/ghostty/themes/nocturne" "$BACKUP_DIR/ghostty-nocturne"
    if [ -f "$SCRIPT_DIR/ghostty.conf" ]; then
        cp "$SCRIPT_DIR/ghostty.conf" "$HOME/.config/ghostty/themes/nocturne"
    elif [ -f "$THEME_DIR/ghostty.conf" ]; then
        cp "$THEME_DIR/ghostty.conf" "$HOME/.config/ghostty/themes/nocturne"
    fi
    echo " -> Applied theme to Ghostty Terminal."
fi

# 5. Kitty
if is_selected "kitty"; then
    mkdir -p "$HOME/.config/kitty"
    [ -f "$HOME/.config/kitty/theme.conf" ] && cp "$HOME/.config/kitty/theme.conf" "$BACKUP_DIR/kitty-theme.conf"
    if [ -f "$SCRIPT_DIR/kitty.conf" ]; then
        cp "$SCRIPT_DIR/kitty.conf" "$HOME/.config/kitty/theme.conf"
    elif [ -f "$THEME_DIR/kitty.conf" ]; then
        cp "$THEME_DIR/kitty.conf" "$HOME/.config/kitty/theme.conf"
    fi
    echo " -> Applied theme to Kitty Terminal."
fi

# 6. Alacritty
if is_selected "alacritty"; then
    mkdir -p "$HOME/.config/alacritty"
    if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
        [ ! -f "$BACKUP_DIR/alacritty.toml" ] && cp "$HOME/.config/alacritty/alacritty.toml" "$BACKUP_DIR/alacritty.toml"
    fi
    if [ -f "$HOME/.local/share/omarchy/config/alacritty/alacritty.toml" ]; then
        cp "$HOME/.local/share/omarchy/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    fi
    echo " -> Applied theme to Alacritty Terminal (preserved font size)."
fi

# 7. Foot
if is_selected "foot"; then
    mkdir -p "$HOME/.config/foot"
    [ -f "$HOME/.config/foot/foot.ini" ] && cp "$HOME/.config/foot/foot.ini" "$BACKUP_DIR/foot.ini"
    if [ -f "$SCRIPT_DIR/foot.ini" ]; then
        cp "$SCRIPT_DIR/foot.ini" "$HOME/.config/foot/foot.ini"
    elif [ -f "$THEME_DIR/foot.ini" ]; then
        cp "$THEME_DIR/foot.ini" "$HOME/.config/foot/foot.ini"
    fi
    echo " -> Applied theme to Foot Terminal."
fi

# 8. GTK
if is_selected "gtk"; then
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    [ -f "$HOME/.config/gtk-3.0/gtk.css" ] && cp "$HOME/.config/gtk-3.0/gtk.css" "$BACKUP_DIR/gtk-3.0-gtk.css"
    [ -f "$HOME/.config/gtk-4.0/gtk.css" ] && cp "$HOME/.config/gtk-4.0/gtk.css" "$BACKUP_DIR/gtk-4.0-gtk.css"
    
    SRC_GTK="$SCRIPT_DIR/gtk.css"
    [ ! -f "$SRC_GTK" ] && SRC_GTK="$THEME_DIR/gtk.css"
    
    if [ -f "$SRC_GTK" ]; then
        cp "$SRC_GTK" "$HOME/.config/gtk-3.0/gtk.css"
        cp "$SRC_GTK" "$HOME/.config/gtk-4.0/gtk.css"
    fi
    
    cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
EOF
    cat > "$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
EOF
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    fi
    echo " -> Applied theme to GTK & Nautilus (dark mode + custom gtk.css)."
fi

# 9. Firefox
if is_selected "firefox"; then
    SRC_FF="$SCRIPT_DIR/firefox.css"
    [ ! -f "$SRC_FF" ] && SRC_FF="$THEME_DIR/firefox.css"
    
    for PROFILE in "${FF_PROFILES[@]}"; do
        mkdir -p "$PROFILE/chrome"
        [ -f "$PROFILE/chrome/userChrome.css" ] && cp "$PROFILE/chrome/userChrome.css" "$BACKUP_DIR/firefox-userChrome-$(basename "$PROFILE").css"
        
        if [ -f "$SRC_FF" ]; then
            cp "$SRC_FF" "$PROFILE/chrome/userChrome.css"
        fi
        
        USER_JS="$PROFILE/user.js"
        if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$USER_JS" 2>/dev/null; then
            echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$USER_JS"
        fi
        echo " -> Applied Firefox theme & enabled userChrome.css to profile $(basename "$PROFILE") (Restart Firefox for changes to take effect)."
    done
fi

# 10. Chromium
if is_selected "chromium"; then
    CHROMIUM_CONFIG_DIR="$HOME/.config/chromium/Default/User StyleSheets"
    mkdir -p "$CHROMIUM_CONFIG_DIR"
    [ -f "$CHROMIUM_CONFIG_DIR/Custom.css" ] && cp "$CHROMIUM_CONFIG_DIR/Custom.css" "$BACKUP_DIR/chromium-Custom.css"
    
    SRC_CHROMIUM="$THEME_DIR/chromium.theme"
    [ ! -f "$SRC_CHROMIUM" ] && SRC_CHROMIUM="$SCRIPT_DIR/chromium.theme"
    [ -f "$SRC_CHROMIUM" ] && cp "$SRC_CHROMIUM" "$CHROMIUM_CONFIG_DIR/Custom.css"
    
    echo " -> Applied theme to Chromium."
fi

# Branding update
BRANDING_DIR="$HOME/.config/omarchy/branding"
mkdir -p "$BRANDING_DIR"
[ -f "$BRANDING_DIR/about.txt" ] && cp "$BRANDING_DIR/about.txt" "$BACKUP_DIR/about.txt"
cat > "$BRANDING_DIR/about.txt" <<'EOF'
                   -`
                   .o+`
                  `ooo/
                 `+oooo:
                `+oooooo:
                -+oooooo+:
              `/:-:++oooo+:
             `/++++/+++++++:
            `/++++++++++++++:
           `/+++ooooooooooooo/`
          ./ooosssso++osssssso+`
         .oossssso-````/ossssss+`
        -osssssso.      :ssssssso.
       :osssssss/        osssso+++.
      /ossssssss/        +ssssooo/-
    `/ossssso+/:-        -:/+osssso+-
   `+sso+:-`                 `.-/+oso:
  `++:.                           `-/+/
  .`                                 `
EOF
echo "Applied Arch ASCII branding to about.txt"

# Activate Omarchy system theme
if command -v omarchy-theme-set &>/dev/null; then
    omarchy-theme-set "nocturne" 2>/dev/null || true
elif command -v omarchy &>/dev/null; then
    omarchy theme set "nocturne" 2>/dev/null || true
fi

echo "=== $THEME_NAME installation complete! ==="
