# Developer Workstation Setup Script

![neo-70s](./images/neo-70s.jpg)

Welcome to your new **ultimate development environment**! A total re-write and re-imagining of [Fedora and Centos Ultimate Setup Scripts](https://github.com/David-Else/fedora-ultimate-setup-script).

- Detects if you are running Fedora or a RHEL clone and adjusts packages and their sources automatically
- Installs all required repositories for your custom software selection
- Removes crufty and junk software
- Installs excellent software and sets up entire system
- Makes improvements to Gnome desktop and font settings
- Uses [stow](https://www.gnu.org/software/stow/) to install and mange dotfiles

# Features

## Compatible with Fedora 34+ and RHEL 8+ and clones

![rocky-fedora-logos](./images/rocky-fedora.png)

Works across Fedora 34+ and RHEL 8+ and all clones. You get to choose between **cutting edge** Fedora or **stable secure** RHEL clones. I suggest if you want stable, then choose Rocky.

\*\* We have entered a new era since the betrayal of Centos users, now we shall never utter the word 'Centos' again, but instead we shall sing the glories of [Rocky Linux](https://rockylinux.org/), and let us not forget in our enthusiasm the awesome [Alma Linux](https://almalinux.org/).

## Intelligent package and repository selection

To maintain parity with Fedora 34+, any package that is not available directly in RHEL is downloaded as:

- A binary from Github or another trusted source
- From [flathub](https://flathub.org/home)

## Terminal and VIM key compatibility where possible

- Setup out of the box with the latest [Neovim 0.5](https://neovim.io/news/2021/07) configured to use `fzf`, `ripgrep` and `bat` with an attractive Visual Studio Code theme

![Neovim](./images/neo-vim-with-vs-code-theme-preview.png)

- [nnn](https://github.com/jarun/nnn) file browser means no need to leave the terminal or abandon common sense VIM keys to explore your computers file system

## Great software out of the box, easy to customize and choose your own

### Browsers

- Firefox
- Chromium
- nnn file browser

### Graphics and photography

- Krita
- Shotwell
- ImageMagick

### Sound and video

- MPV
- Handbrake
- MKVToolNix

### Security and backup

- KeepassXC
- BorgBackup

### Development tools

- Visual Studio Code (now optional, uncomment in script)
- Neovim 0.5 fully configured with treesitter/lsp/nvim-compe/fzf
- Node.js / Deno
- Podman
- Gnome Boxes
- Lazygit
- Github CLI
- Pandoc
- Shellcheck / shfmt
- Bat / ripgrep

## Communications

- Thunderbird
- Signal Messenger

# Installation

## Before you run this script

This script is designed to be run immediately after installing the operating system. If you are using a RHEL clone you should select `workstation` from the software selection option during the install.

![RHEL](./images/centos-8-install-options.png)

## Prior customization

You will want to look at the script and modify it with your own preferences. This has been made as easy as possible, and should be self explanatory. `rpm_packages_to_remove rpm_packages_to_install flathub_packages_to_install npm_global_packages_to_install` arrays contain all the packages that are common to Fedora and RHEL clones, inside the `if then` conditional you can add and remove packages specifically for each operating system.

## Clone this repo and run `install.sh` and `setup.sh`
```
git clone https://github.com/David-Else/developer-workstation-setup-script
cd developer-workstation-setup-script
sudo ./install.sh
./setup.sh
```

**ENJOY!**

# FAQ

**Q**: Why is the script spit into two parts for install and setup?

**A**: Sudo privileges are needed for the installation, and they time out before the script can finish. This makes unattended installation impossible without running the install part of the script as root.

The setup part is much easier to do as a user, so running it as the user avoids constant `su - "$SUDO_USER" -c` statements in the code. If a part of the setup needs `sudo` it will ask for it for just that part.

**Q**: Does this script disable the caps lock key? I've noticed that it works during login but after that it stops working altogether.

**A**: It makes the caps lock into a delete for touch typing purposes, to change it modify this line in the setup script before running:

```shell
 capslock_delete="false"
```
