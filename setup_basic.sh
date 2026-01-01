#!/data/data/com.termux/files/usr/bin/bash

# Init
echo "Termux Setup (Basic)"
echo "Hello $(whoami), starting setup..."

cd "$HOME"
pkg update -y
pkg upgrade -y
pkg install x11-repo tur-repo root-repo -y
apt autoclean -y
apt autoremove -y
termux-setup-storage

# Configure
echo "Installing Custom Font..."
pkg install curl -y
rm -f "$HOME/.termux/font.ttf"
curl -L -o "$HOME/.termux/font.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/patched-fonts/Noto/Mono/NotoMonoNerdFontMono-Regular.ttf"

# Make .bashrc
echo "Setting up custom .bashrc..."
cat > "$HOME/.bashrc" << EOF
# Cache cleanup
clear && ( apt autoclean -y && apt autoremove -y ) >/dev/null 2>&1
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
EOF

# Finalizing
echo "Finalizing..."
clear
termux-reload-settings
bash "$HOME/.bashrc"
exit 0
