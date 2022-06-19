#!/bin/bash
set -euo pipefail
sudo --validate

BIN_INSTALL_DIR=/usr/local/bin
PANDOC_FILTER_DIR="$HOME"/.local/share/pandoc/filters
PANDOC_DL_URL="https://raw.githubusercontent.com/pandoc/lua-filters/master"
TMP=./temp

# ${1} version ${2} repo ${3} regex pattern
download() {
    gh release download --dir $TMP "$1" --repo "$2" --pattern "$3"
}

# ${1} filename ${2} strip ${3} new name for shell command
install() {
    sudo tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
}

download_args() {
    $1 2.18 jgm/pandoc "*linux-amd64.tar.gz"
    $1 v0.8.0 koalaman/shellcheck "*linux.x86_64.tar.xz"
    $1 v3.5.1 mvdan/sh "*linux_amd64"
    $1 13.0.0 BurntSushi/ripgrep "*x86_64-unknown-linux-musl.tar.gz"
    $1 v0.21.0 sharkdp/bat "*x86_64-unknown-linux-musl.tar.gz"
    $1 v2.18.0 errata-ai/vale "*Linux_64-bit.tar.gz"
    $1 15.2.0 valentjn/ltex-ls "*ltex-ls-15.2.0.tar.gz"
    $1 0.13.0 dandavison/delta "*x86_64-unknown-linux-musl.tar.gz"
}

install_args() {
    $1 "$TMP/pandoc-2.18-linux-amd64.tar.gz" 2 pandoc
    $1 "$TMP/shellcheck-v0.8.0.linux.x86_64.tar.xz" 1 shellcheck
    $1 "$TMP/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz" 1 rg
    $1 "$TMP/bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz" 1 bat
    $1 "$TMP/vale_2.18.0_Linux_64-bit.tar.gz" 0 vale
    $1 "$TMP/delta-0.13.0-x86_64-unknown-linux-gnu.tar.gz" 1 delta
    $1 "$TMP/ltex-ls-15.2.0.tar.gz" 1 bin
    $1 "$TMP/ltex-ls-15.2.0.tar.gz" 1 lib
}

mkdir -p $TMP
download_args download
install_args install
sudo ln --symbolic --force $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls

# shfmt
chmod +x "$TMP/shfmt_v3.5.1_linux_amd64"
sudo cp -i "$TMP/shfmt_v3.5.1_linux_amd64" $BIN_INSTALL_DIR/shfmt

# kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/ $BIN_INSTALL_DIR
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

# ytfzf
git clone -b v2.3 https://github.com/pystardust/ytfzf $TMP
cd $TMP/ytfzf || exit 1
sudo make install doc
cd -

# deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# nnn plugins
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

# pandoc filters
mkdir -p "$PANDOC_FILTER_DIR"
curl $PANDOC_DL_URL/wordcount/wordcount.lua -o "$PANDOC_FILTER_DIR"/wordcount.lua
curl $PANDOC_DL_URL/diagram-generator/diagram-generator.lua -o "$PANDOC_FILTER_DIR"/diagram-generator.lua
curl $PANDOC_DL_URL/pagebreak/pagebreak.lua -o "$PANDOC_FILTER_DIR"/pagebreak.lua
curl $PANDOC_DL_URL/include-files/include-files.lua -o "$PANDOC_FILTER_DIR"/include-files.lua
curl $PANDOC_DL_URL/include-code-files/include-code-files.lua -o "$PANDOC_FILTER_DIR"/include-code-files.lua

# install Paq plugin manager for Neovim
git clone --depth=1 https://github.com/savq/paq-nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim
# add dictionary file so custom function does not give error
mkdir -p "$HOME"/.config/nvim/spell && touch "$HOME"/.config/nvim/spell/en.utf-8.add

# remove temp files
rm -rf $TMP

echo "Finished!"
