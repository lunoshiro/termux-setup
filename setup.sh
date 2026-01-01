#!/data/data/com.termux/files/usr/bin/bash
# Helper Function
ask() {
  local prompt="$1" default="$2" answer

  while true; do
    if [ "$default" = "y" ]; then
      echo -n "$prompt (Y/n): "
    else
      echo -n "$prompt (y/N): "
    fi
    read answer
    [ -z "$answer" ] && answer="$default"
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    case "$answer" in
      y | yes) return 0 ;;
      n | no) return 1 ;;
      *) echo "Invalid choice, try again." ;;
    esac
  done
}

choice() {
  local title="" outvar="choice_output" input
  local keys=() labels=()

  while (($#)); do
    case $1 in
      -t)
        title=$2
        shift 2
        ;;
      -c)
        keys+=("$2")
        labels+=("$3")
        shift 3
        ;;
      -ov)
        outvar=$2
        shift 2
        ;;
      *) shift ;;
    esac
  done

  [[ $title ]] && echo "$title"
  for i in "${!keys[@]}"; do
    printf "%s) %s\n" "${keys[i]}" "${labels[i]}"
  done

  while true; do
    read -rp "Select: " input
    input="${input//[[:space:]]/}"

    for i in "${!keys[@]}"; do
      [[ $input == "${keys[i]}" ]] && {
        printf -v "$outvar" %s "$input"
        return 0
      }
    done

    echo "Invalid choice."
  done
}

# Initial
echo "Termux Setup"
if ask "Hello $(whoami), Do you want to start setup" y; then
  if [ $(($(date +%s) - $(stat -c %Y $PREFIX))) -le 3600 ] || ask "It looks like your termux is not freshly installed (You can use termux-reset or go to app settings and clear data to reset your termux) or Do you want to continue anyway (may break your current setup)?" n; then
    cd "$HOME"
    pkg update -y
    pkg upgrade -y
    pkg install x11-repo tur-repo root-repo -y
    apt autoclean -y
    apt autoremove -y
    termux-setup-storage

    if ask "Download and Install Noto Nerd Font" y; then
      pkg install curl xz-utils fontconfig fontconfig-utils jq -y
      rm -rf "$PREFIX/share/fonts/Noto"
      mkdir -p "$PREFIX/share/fonts/Noto"
      curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r .tag_name)/Noto.tar.xz" | tar -xJ -C "$PREFIX/share/fonts/Noto"
      chmod 644 "$PREFIX/share/fonts/Noto/*"
      fc-cache -fv
      mkdir -p "$HOME/.termux"
      rm -f "$HOME/.termux/font.ttf"
      cp "$PREFIX/share/fonts/Noto/NotoMonoNerdFontMono-Regular.ttf" "$HOME/.termux/font.ttf"
    fi

    if ask "Apply Tokyo Night colorscheme" y; then
      cat > "$HOME/.termux/colors.properties" << 'EOF'
# Tokyo Night color scheme
foreground=#a9b1d6
background=#1a1b26
cursor=#c0caf5

color0=#414868
color1=#f7768e
color2=#73daca
color3=#e0af68
color4=#7aa2f7
color5=#bb9af7
color6=#7dcfff
color7=#c0caf5

color8=#414868
color9=#f7768e
color10=#73daca
color11=#e0af68
color12=#7aa2f7
color13=#bb9af7
color14=#7dcfff
color15=#c0caf5
EOF
    fi

    if ask "Install Fastfetch with custom config" y; then
      pkg install fastfetch -y
      mkdir -p "$HOME/fastfetch"
      cat > "$HOME/fastfetch/config.jsonc" << 'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

  "logo": {
    "type": "small",
    "padding": { "right": 2 }
  },

  "display": {
    "separator": " : "
  },

  "modules": [
    "title",
    "break",
    { "type": "host",   "key": "host", "keyColor": "green" },
    { "type": "os",     "key": "os" },
    { "type": "cpu",    "key": "cpu" },
    { "type": "gpu",    "key": "gpu" },
    { "type": "kernel", "key": "kernel" },
    { "type": "packages", "key": "pkgs" },
    { "type": "uptime",   "key": "uptime" },
    { "type": "memory",   "key": "memory" },
    { "type": "disk", "key": "disk" },
    "break",
    { "type": "colors", "symbol": "circle" }
  ]
}
EOF

      # Ask run fastfetch
      if ask "Run fastfetch on start" n; then
        RUN_FASTFETCH=1
      else
        RUN_FASTFETCH=0
      fi

      # Ask for logo in fastfetch
      if ask "Add OS logo to fastfetch output" y; then
        FASTFETCH_LOGO=1
      else
        FASTFETCH_LOGO=0
      fi
    fi

    # Configure Desktop Environment
    XFCE_INSTALLED=0
    I3_INSTALLED=0
    if ask "Install desktop environment" n; then
      pkg install x11-repo tur-repo -y
      pkg install angle-android virglrenderer-android -y
      pkg install mesa-demos -y
      pkg install termux-x11-nightly pulseaudio pavucontrol -y

      # DESKTOP ENVIRONMENT SELECTION
      choice -t "Select Desktop Environment/Window Nanager:" -c 1 "XFCE (Desktop Environment)" -c 2 "i3 (Window Manager) (Install Only)" -c 0 "No Desktop Environment" -ov desk_choice

      # OPTION 1 — XFCE
      if [[ $desk_choice == "1" ]]; then
        XFCE_INSTALLED=1
        echo "Installing XFCE Desktop Environment..."
        pkg install xfce4 xfce4-goodies -y

        # Launcher
        cat > "$HOME/.termux/.startxfce4" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

killall -9 termux-wake-lock pulseaudio virgl_test_server_android $(pgrep -f "termux.x11")

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

# virgl_test_server_android &
virgl_test_server_android --angle-gl &

export XDG_RUNTIME_DIR=${TMPDIR}
export PULSE_SERVER=127.0.0.1

termux-x11 :0 &
sleep 3
am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

env DISPLAY=:0 dbus-launch --exit-with-session startxfce4 &
EOF
        chmod +x "$HOME/.termux/.startxfce4"
      fi

      # OPTION 2 — i3 WINDOW MANAGER
      if [[ $desk_choice == "2" ]]; then
        I3_INSTALLED=1
        echo "Installing i3 Window Manager..."
        pkg install i3 -y

        # Launcher
        cat > "$HOME/.termux/.starti3" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

killall -9 termux-wake-lock pulseaudio virgl_test_server_android $(pgrep -f "termux.x11")

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

# virgl_test_server_android &
virgl_test_server_android --angle-gl &

export XDG_RUNTIME_DIR=${TMPDIR}
export PULSE_SERVER=127.0.0.1

termux-x11 :0 &
sleep 3
am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

env DISPLAY=:0 dbus-launch --exit-with-session i3 &
EOF
        chmod +x "$HOME/.termux/.starti3"
      fi

      # OPTION 0 — NO DESKTOP
      if [[ $desk_choice == "0" ]]; then
        echo "No Desktop Environment selected. Skipping..."
      fi

      if ask "Install FireFox" y; then
        pkg install firefox -y
      fi
      if ask "Install Code OSS" y; then
        pkg install code-oss -y
      fi

    fi

    # Install rish (Shizuku)
    if ask "Install rish (ADB Shell access, Required Shizuku installed!)" n; then
      # Root check
      if [ "$(id -u)" = 0 ]; then
        echo "Don't run as root, skipping..."
      else
        # Ensure tools exist
        echo "Checking tools..."
        pkg install curl jq unzip sed -y
        # Fetch release URL
        echo "Fetching latest Shizuku release..."
        SHIZUKU_APK_URL=$(curl -sL https://api.github.com/repos/RikkaApps/Shizuku/releases/latest | jq -r 'select(.prerelease==false) | .assets[] | select(.name|endswith(".apk")) | .browser_download_url' | head -n1)
        if [ -z "$SHIZUKU_APK_URL" ]; then
          echo "Failed to get APK URL, skipping..."
        else
          TMPDIR=$(mktemp -d)
          echo "Downloading APK..."
          if ! curl -sL -o "$TMPDIR/S.apk" "$SHIZUKU_APK_URL"; then
            echo "Download failed, skipping..."
          else
            echo "Extracting..."
            unzip -q "$TMPDIR/S.apk" -d "$TMPDIR"
            if [ ! -f "$TMPDIR/assets/rish" ] || [ ! -f "$TMPDIR/assets/rish_shizuku.dex" ]; then
              echo "Missing files in APK, skipping..."
            else
              # Install section
              BIN=$(dirname "$(command -v sh)")
              RISH="$BIN/rish"
              echo "Installing..."
              install -m644 "$TMPDIR/assets/rish_shizuku.dex" "$BIN/"
              install -m755 "$TMPDIR/assets/rish" "$BIN/"
              sed -i '/^#/d;s/PKG/com.termux/g' "$RISH"
              echo "Done! rish installed to $RISH"
            fi
          fi
          rm -rf "$TMPDIR" 2> /dev/null
        fi
      fi
    fi

    # Make .bashrc
    if ask "Setup custom .bashrc" y; then
      cat > "$HOME/.bashrc" << EOF
# Cache cleanup
clear && echo "Loading..." && ( apt autoclean -y && apt autoremove -y ) >/dev/null 2>&1
clear

# Custom PS1
PS1='[\u@\h \[\e[0;32m\]\w\[\e[0m\]] \[\e[0;97m\]\$\[\e[0m\] '

# Aliases
alias cp='cp -rv'
alias ls='ls --color=auto -ACF'
alias ll='ls -lhA'
alias mv='mv -v'
alias mkdir='mkdir -pv'
alias rf='rm -rf'
alias wget='wget -c'
alias fhere="find . -name "
alias ..='cd ..'
alias histg="history | grep"
$([ "${XFCE_INSTALLED:-0}" -eq 1 ] && echo "alias startxfce='sh \$HOME/.termux/.startxfce4'")
$([ "${XFCE_INSTALLED:-0}" -eq 1 ] && echo "alias sxfce='sh \$HOME/.termux/.startxfce4'")
$([ "${XFCE_INSTALLED:-0}" -eq 1 ] && echo "alias de='sh \$HOME/.termux/.startxfce4'")
$([ "${I3_INSTALLED:-0}" -eq 1 ] && echo "alias starti3='sh \$HOME/.termux/.starti3'")
$([ "${I3_INSTALLED:-0}" -eq 1 ] && echo "alias si3='sh \$HOME/.termux/.starti3'")
$([ "${I3_INSTALLED:-0}" -eq 1 ] && echo "alias de='sh \$HOME/.termux/.starti3'")
$([ "${FASTFETCH_LOGO:-0}" -eq 0 ] && echo "alias fastfetch='\$PREFIX/bin/fastfetch -l none'")
$([ "${RUN_FASTFETCH:-0}" -eq 1 ] && echo fastfetch)
EOF
    fi
  fi
fi

# Finalizing
echo "Finalizing"
apt autoclean -y
apt autoremove -y
termux-reload-settings
clear
bash "$HOME/.bashrc"
exit 0
