#!/bin/bash
set -euo pipefail
source colors.bash
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
    echo -e "Downloading ${GREEN}${2}${RESET}..."
    gh release download --dir $TMP "$1" --repo "$2" --pattern "$3"
}

# ${1} filename ${2} strip ${3} new name for shell command
install() {
    (cd $TMP && sudo tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf ./${1} --no-anchored "${3}" --strip="${2}")

}

# TODO add https://github.com/tamasfe/taplo/releases https://github.com/artempyanykh/marksman
download 2.18 jgm/pandoc "*linux-amd64.tar.gz"
download v3.5.1 mvdan/sh "*linux_amd64"
download 13.0.0 BurntSushi/ripgrep "*x86_64-unknown-linux-musl.tar.gz"
download v0.21.0 sharkdp/bat "*x86_64-unknown-linux-musl.tar.gz"
download v2.19.0 errata-ai/vale "*Linux_64-bit.tar.gz"
download 15.2.0 valentjn/ltex-ls "*ltex-ls-15.2.0.tar.gz"
download 0.13.0 dandavison/delta "*x86_64-unknown-linux-musl.tar.gz"

install "pandoc*" 2 pandoc # https://bugzilla.redhat.com/show_bug.cgi?id=2035151
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

# deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# pandoc filters
mkdir -p "$PANDOC_FILTER_DIR"
curl $PANDOC_DL_URL/wordcount/wordcount.lua -o "$PANDOC_FILTER_DIR"/wordcount.lua
curl $PANDOC_DL_URL/diagram-generator/diagram-generator.lua -o "$PANDOC_FILTER_DIR"/diagram-generator.lua
curl $PANDOC_DL_URL/pagebreak/pagebreak.lua -o "$PANDOC_FILTER_DIR"/pagebreak.lua
curl $PANDOC_DL_URL/include-files/include-files.lua -o "$PANDOC_FILTER_DIR"/include-files.lua
curl $PANDOC_DL_URL/include-code-files/include-code-files.lua -o "$PANDOC_FILTER_DIR"/include-code-files.lua

# blender
sudo mkdir -p "$BIN_INSTALL_DIR/blender-bin"
curl -O https://download.blender.org/release/Blender3.3/blender-3.3.1-linux-x64.tar.xz
sudo tar -xvf blender-3.3.1-linux-x64.tar.xz -C "$BIN_INSTALL_DIR/blender-bin"/ --strip=1
sudo ln --symbolic --force $BIN_INSTALL_DIR/blender-bin/blender $BIN_INSTALL_DIR/blender
cp "$BIN_INSTALL_DIR/blender-bin/blender.desktop" ~/.local/share/applications/
sed -i "s|Icon=blender|Icon=$BIN_INSTALL_DIR/blender-bin/blender.svg|g" ~/.local/share/applications/blender*.desktop

# remove temp files
rm -rf $TMP
rm blender-3.2.1-linux-x64.tar.xz

display_text "
${BOLD}Finished!${RESET}

GitHub binaries have been installed to ${GREEN}${BIN_INSTALL_DIR}${RESET}
Pandoc filters have been installed to ${GREEN}${PANDOC_FILTER_DIR}${RESET}

"
