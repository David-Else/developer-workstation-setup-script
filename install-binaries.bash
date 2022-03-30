#!/bin/bash
set -euo pipefail

sudo --validate

source colors.bash
source functions.bash

confirm_user_is 'normal'

# ${1} version ${2} repo ${3} regex pattern
download() {
    echo -e "Downloading ${GREEN}${2}${RESET}..."
    gh release download --dir "./" "$1" --repo "$2" --pattern "$3"
}

# Extracts a file from a tar archieve into a directory
# ${1} filename ${2} strip ${3} newname
install() {
    if [ -f "$BIN_INSTALL_DIR"/"$3" ]; then
        echo -e "${GREEN}$3${RESET} was previously installed"
        read -p "Would you like to keep the existing version? " -n 1 -r && echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return
        fi

    fi
    sudo tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
}

BIN_INSTALL_DIR=/usr/local/bin
PANDOC_FILTER_DIR="$HOME"/.local/share/pandoc/filters

PANDOC_VERSION=2.17.1.1
SHELLCHECK_VERSION=0.8.0
SHFMT_VERSION=3.4.3
RIPGREP_VERSION=13.0.0
BAT_VERSION=0.19.0
VALE_VERSION=2.15.4
STYLUA_VERSION=0.12.5
LTEXLS_VERSION=15.2.0
DELTA_VERSION=0.11.3

PANDOC_FILENAME=pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz
SHELLCHECK_FILENAME=shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz
SHFMT_FILENAME=shfmt_v${SHFMT_VERSION}_linux_amd64
RIPGREP_FILENAME=ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz
BAT_FILENAME=bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz
VALE_FILENAME=vale_${VALE_VERSION}_Linux_64-bit.tar.gz
STYLUA_FILENAME=stylua-${STYLUA_VERSION}-linux.zip
LTEXLS_FILENAME=ltex-ls-${LTEXLS_VERSION}.tar.gz
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
download $DELTA_VERSION dandavison/delta "*x86_64-unknown-linux-gnu.tar.gz"

install "$PANDOC_FILENAME" "2" "pandoc"
install "$SHELLCHECK_FILENAME" "1" "shellcheck"
install "$RIPGREP_FILENAME" "1" "rg"
install "$BAT_FILENAME" "1" "bat"
install "$VALE_FILENAME" "0" "vale"
install "$DELTA_FILENAME" "1" "delta"

# install stylua
sudo unzip -d $BIN_INSTALL_DIR $STYLUA_FILENAME
sudo chmod +x "$BIN_INSTALL_DIR/stylua"

# install ltex-ls
sudo tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf $LTEXLS_FILENAME --no-anchored 'bin' --strip=1
sudo tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf $LTEXLS_FILENAME --no-anchored 'lib' --strip=1
sudo ln --symbolic --force $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls

# install vimplug
mkdir -p "$HOME"/.config/nvim/plugged
curl -fLo "$HOME"/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install shfmt
chmod +x $SHFMT_FILENAME
sudo cp -i $SHFMT_FILENAME $BIN_INSTALL_DIR/shfmt

# remove temp files
compgen -A variable -X '!*_FILENAME*' | while read line; do rm "${!line}"; done

# install ytfzf
git clone -b v2.2 https://github.com/pystardust/ytfzf
cd ytfzf || exit 1
sudo make install doc
cd ..
rm -rf ./ytfzf

# install deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# install kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln --symbolic --force ~/.local/kitty.app/bin/kitty $BIN_INSTALL_DIR
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop

# install nnn plugins
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

# install pandoc filters
mkdir -p "$PANDOC_FILTER_DIR"
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/wordcount/wordcount.lua -o "$PANDOC_FILTER_DIR"/wordcount.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/diagram-generator/diagram-generator.lua -o "$PANDOC_FILTER_DIR"/diagram-generator.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/pagebreak/pagebreak.lua -o "$PANDOC_FILTER_DIR"/pagebreak.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/include-files/include-files.lua -o "$PANDOC_FILTER_DIR"/include-files.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/include-code-files/include-code-files.lua -o "$PANDOC_FILTER_DIR"/include-code-files.lua

display_text "

${BOLD}Finished!${RESET}

Now install the setup with ${GREEN}./setup.sh${RESET}...

"
