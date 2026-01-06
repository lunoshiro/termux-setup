# Termux Setup
Automated setup script for [Termux](https://github.com/termux/termux-app).
<details>
<summary><strong>Details</strong></summary>

- **Name**: Termux Setup
- **Version**: 1.0
- **Language**: Bash

</details>


## Features
- **Terminal Customization (Font and Theme)**
- **Custom .bashrc**: Custom productivity aliases, shortcut and enhanced commands
- **Desktop Environment**: via Termux:X11
- **Audio Support (PluseAudio)**
- **ADB Shell Access**: using ([Shizuku](https://github.com/RikkaApps/Shizuku))
<details>
<summary><strong>Notes:</strong></summary>

- For basic version available features is only **Custom Fonts** and **Custom .bashrc**

</details>


## Requirements
- [Termux app](https://github.com/termux/termux-app)
- Android 7.0+
- 6GB storage recommend (4GB minimal)
- 8GB RAM recommended (4GB minimal)
- Stable internet connection
- [Termux:X11](https://github.com/termux/termux-x11) app (Optional for Displaying Desktop Environment)


## Installation
```bash
curl -fsSL https://raw.githubusercontent.com/lunoshiro/termux-setup/refs/heads/main/setup.sh -o setup.sh && bash setup.sh && rm setup.sh
```
<details>
<summary><strong>Basic Version</strong></summary>

### Basic Version
```bash
curl -fsSL https://raw.githubusercontent.com/lunoshiro/termux-setup/refs/heads/main/setup_basic.sh -o setup_basic.sh && bash setup_basic.sh && rm setup_basic.sh
```

</details>
<details>
<summary><strong>Post-Installation</strong></summary>

### Post-Installation
Restart Termux to apply all configurations. Verify font rendering and test aliases with `alias` command.

</details>


## Usage
<details>
<summary><strong>Usage...</strong></summary>

### Shell Aliases
```bash
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
```
View all aliases: `alias`

### Desktop Usage
```bash
startxfce    # Launch XFCE4 desktop
starti3      # Launch I3 desktop
DE         # Launch XFCE4 or I3 based on selection
```

</details>


## Troubleshooting
- **Installation fails**: Check internet connection and storage space  
- **Font not applied**: Restart Termux, verify `~/.termux/font.ttf` exists
- **Package errors**: Run `pkg update && pkg clean` then retry, if the issues still occurred try change repo `termux-change-repo`
- **Desktop issues** (Full only): Update Termux:X11, grant required permissions


## Configuration Files
- Font: `~/.termux/font.ttf`
- Shell: `~/.bashrc`
- Colors: `~/.termux/colors.properties`
- Fastfetch: `~/fastfetch/config.jsonc`
- Desktop: `~/.termux/.startxfce4` or  `~/.termux/.starti3`


## Credits
### This project uses the following components:
- **[Termux](https://github.com/termux/termux-app)** - Android terminal emulator
- **[Termux:X11](https://github.com/termux/termux-x11)** - X11 server implementation for Termux
- **[Noto](https://notofonts.github.io) + [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)** - A typeface for the world + nerd-fonts
- **[Tokyo Night](https://github.com/tokyo-night/tokyo-night-vscode-theme)** - Color scheme
- **[Fastfetch](https://github.com/fastfetch-cli/fastfetch)** - System information tool
- **[XFCE](https://www.xfce.org/)** - a lightweight desktop environment
- **[i3](https://i3wm.org/)** - tiling window manager
- **[PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/)** - Sound server
- **[Shizuku](https://github.com/RikkaApps/Shizuku)** - Let your app use system APIs directly


## Contributing & Support
Issues and pull requests are welcome. Please include credits to this repository when using or modifying.

## License
This project is released under the MIT License.
See the [LICENSE](./LICENSE) file for full terms.
