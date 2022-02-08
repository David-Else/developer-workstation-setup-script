#!/bin/bash
set -euo pipefail

source colors.bash
source functions.bash

confirm_user_is 'root'

# ${1} version ${2} repo ${3} regex pattern
download() {
    echo -e "Downloading ${GREEN}${2}${RESET}..."
    su - "$SUDO_USER" -c "gh release download --dir $WD $1 --repo $2 --pattern $3"
}

WD="$(pwd)"
BIN_INSTALL_DIR=/usr/local/bin

PANDOC_VERSION=2.17.1.1
SHELLCHECK_VERSION=0.8.0
SHFMT_VERSION=3.4.2
RIPGREP_VERSION=13.0.0
BAT_VERSION=0.19.0
VALE_VERSION=2.14.0
STYLUA_VERSION=0.12.1
LTEXLS_VERSION=15.2.0
NVIM_VERSION=0.6.1
DELTA_VERSION=0.11.3

PANDOC_FILENAME=pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz
SHELLCHECK_FILENAME=shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz
SHFMT_FILENAME=shfmt_v${SHFMT_VERSION}_linux_amd64
RIPGREP_FILENAME=ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz
BAT_FILENAME=bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz
VALE_FILENAME=vale_${VALE_VERSION}_Linux_64-bit.tar.gz
STYLUA_FILENAME=stylua-${STYLUA_VERSION}-linux.zip
LTEXLS_FILENAME=ltex-ls-${LTEXLS_VERSION}.tar.gz
NVIM_FILENAME=nvim.appimage
DELTA_FILENAME=delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz

# print all the programs to install and ask for confirmation
clear
compgen -A variable -X '!*_FILENAME*' |
    while read line; do echo -e "${line/\_FILENAME/} ${GREEN}${!line}${RESET}"; done
read -rp $'\nPress enter to install, or ctrl+c to quit'

echo -e "${BOLD}Installing GitHub binaries${RESET}"

download $PANDOC_VERSION jgm/pandoc "*linux-amd64.tar.gz"
download v$SHELLCHECK_VERSION koalaman/shellcheck "*linux.x86_64.tar.xz"
download v$SHFMT_VERSION mvdan/sh "*linux_amd64"
download $RIPGREP_VERSION BurntSushi/ripgrep "*x86_64-unknown-linux-musl.tar.gz"
download v$BAT_VERSION sharkdp/bat "*x86_64-unknown-linux-gnu.tar.gz"
download v${VALE_VERSION} errata-ai/vale "*Linux_64-bit.tar.gz"
download v$STYLUA_VERSION JohnnyMorganz/StyLua "*linux.zip"
download $LTEXLS_VERSION valentjn/ltex-ls "*ltex-ls-${LTEXLS_VERSION}.tar.gz"
download v$NVIM_VERSION neovim/neovim "*.appimage"
download $DELTA_VERSION dandavison/delta "*x86_64-unknown-linux-gnu.tar.gz"

install "$PANDOC_FILENAME" "2" "pandoc"
install "$SHELLCHECK_FILENAME" "1" "shellcheck"
install "$RIPGREP_FILENAME" "1" "rg"
install "$BAT_FILENAME" "1" "bat"
install "$VALE_FILENAME" "0" "vale"
install "$DELTA_FILENAME" "1" "delta"

# install stylua
unzip -d $BIN_INSTALL_DIR $STYLUA_FILENAME
chmod +x "$BIN_INSTALL_DIR/stylua"

# install ltex-ls
tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf $LTEXLS_FILENAME --no-anchored 'bin' --strip=1
tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf $LTEXLS_FILENAME --no-anchored 'lib' --strip=1

if [ ! -f "$BIN_INSTALL_DIR/bin/ltex-ls" ]; then
    ln -s $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls
fi

# install neovim and vimplug
chmod +x $NVIM_FILENAME
cp -i $NVIM_FILENAME $BIN_INSTALL_DIR/nvim
su - "$SUDO_USER" -c "mkdir -p /home/$SUDO_USER/.config/nvim/plugged"
su - "$SUDO_USER" -c "curl -fLo /home/$SUDO_USER/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
su - "$SUDO_USER" -c "xdg-desktop-menu install --novendor ${WD}/nvim.desktop"
su - "$SUDO_USER" -c "xdg-icon-resource install --novendor --mode user --size 64 ${WD}/nvim.png"

# install shfmt
chmod +x $SHFMT_FILENAME
cp -i $SHFMT_FILENAME $BIN_INSTALL_DIR/shfmt

# remove temp files
compgen -A variable -X '!*_FILENAME*' | while read line; do rm "${!line}"; done

# install ytfzf
git clone https://github.com/pystardust/ytfzf
cd ytfzf || exit 1
make install doc
cd ..
rm -rf ./ytfzf

# install deno
su - "$SUDO_USER" -c "curl -fsSL https://deno.land/x/install/install.sh | sh"

# install kitty TEST
su - "$SUDO_USER" -c "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
su - "$SUDO_USER" -c "ln -s ~/.local/kitty.app/bin/kitty $BIN_INSTALL_DIR"
su - "$SUDO_USER" -c "cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/"
su - "$SUDO_USER" -c "sed -i "s | Icon=kitty | Icon=/home/$SUDO_USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png | g" ~/.local/share/applications/kitty.desktop"

# install nnn plugins
su - "$SUDO_USER" -c "curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh"

echo -e "\n${BOLD}Finished!${RESET}"
