#!/bin/bash
set -euo pipefail
source functions.bash
confirm_user_is 'normal'
sudo --validate

BIN_INSTALL_DIR=/usr/local/bin
PANDOC_FILTER_DIR="$HOME"/.local/share/pandoc/filters
PANDOC_DL_URL="https://raw.githubusercontent.com/pandoc/lua-filters/master"
TMP=./temp
mkdir -p $TMP

# ${1} version ${2} repo ${3} regex pattern
download() {
    gh release download --dir $TMP "$1" --repo "$2" --pattern "$3"
}

# ${1} filename ${2} strip ${3} new name for shell command
install() {
    (cd $TMP && sudo tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf ./${1} --no-anchored "${3}" --strip="${2}")

}

download 2.18 jgm/pandoc "*linux-amd64.tar.gz"
download v0.8.0 koalaman/shellcheck "*linux.x86_64.tar.xz"
download v3.5.1 mvdan/sh "*linux_amd64"
download 13.0.0 BurntSushi/ripgrep "*x86_64-unknown-linux-musl.tar.gz"
download v0.21.0 sharkdp/bat "*x86_64-unknown-linux-musl.tar.gz"
download v2.19.0 errata-ai/vale "*Linux_64-bit.tar.gz"
download 15.2.0 valentjn/ltex-ls "*ltex-ls-15.2.0.tar.gz"
download 0.13.0 dandavison/delta "*x86_64-unknown-linux-musl.tar.gz"

install "pandoc*" 2 pandoc
install "shellcheck*" 1 shellcheck
install "ripgrep*" 1 rg
install "bat*" 1 bat
install "vale*" 0 vale
install "delta*" 1 delta
install "ltex*" 1 bin
install "ltex*" 1 lib
sudo ln --symbolic --force $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls

# shfmt
chmod +x "$TMP/shfmt_v3.5.1_linux_amd64"
sudo cp -i "$TMP/shfmt_v3.5.1_linux_amd64" $BIN_INSTALL_DIR/shfmt

# kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln --symbolic --force ~/.local/kitty.app/bin/kitty $BIN_INSTALL_DIR
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

# blender
sudo mkdir -p "$BIN_INSTALL_DIR/blender-bin"
curl -O https://download.blender.org/release/Blender3.2/blender-3.2.0-linux-x64.tar.xz
sudo tar -xvf blender-3.2.0-linux-x64.tar.xz -C "$BIN_INSTALL_DIR/blender-bin"/ --strip=1
sudo ln --symbolic --force $BIN_INSTALL_DIR/blender-bin/blender $BIN_INSTALL_DIR/blender
cp "$BIN_INSTALL_DIR/blender-bin/blender.desktop" ~/.local/share/applications/
sed -i "s|Icon=blender|Icon=$BIN_INSTALL_DIR/blender-bin/blender.svg|g" ~/.local/share/applications/blender*.desktop

# remove temp files dir
rm -rf $TMP
rm blender-3.2.0-linux-x64.tar.xz

echo "Finished!"
