#!/bin/bash
set -euo pipefail
source colors.bash
source functions.bash

confirm_user_is 'normal'
sudo --validate

BIN_INSTALL_DIR=/usr/local/bin
PANDOC_FILTER_DIR="$HOME"/.local/share/pandoc/filters
TMP=./temp
mkdir -p $TMP

# ==================
#  Github Download
# ==================

# ${1} version ${2} repo ${3} regex pattern
download() {
    echo -e "Downloading ${GREEN}${2}${RESET}..."
    gh release download --dir $TMP "$1" --repo "$2" --pattern "$3"
}

declare -A github_packages=(
    ['pandoc']="2.18 jgm/pandoc *linux-amd64.tar.gz"
    ['shellcheck']="v0.8.0 koalaman/shellcheck *linux.x86_64.tar.xz"
    ['shfmt']="v3.5.1 mvdan/sh *linux_amd64"
    ['ripgrep']="13.0.0 BurntSushi/ripgrep *x86_64-unknown-linux-musl.tar.gz"
    ['bat']="v0.21.0 sharkdp/bat *x86_64-unknown-linux-musl.tar.gz"
    ['vale']="v2.18.0 errata-ai/vale *Linux_64-bit.tar.gz"
    ['ltex-ls']="15.2.0 valentjn/ltex-ls *ltex-ls-15.2.0.tar.gz"
    ['delta']="0.13.0 dandavison/delta *x86_64-unknown-linux-gnu.tar.gz"
)

for key in "${!github_packages[@]}"; do
    read -r -a args <<<"${github_packages[$key]}" # allow whitespace expansion and prevent globbing
    download "${args[@]}"
done

# ==================
#      Install
# ==================

# ${1} filename ${2} strip ${3} new name for shell command
install() {
    if [ -f "$BIN_INSTALL_DIR"/"$3" ]; then
        echo -e "${GREEN}$3${RESET} was previously installed, updating"
    fi
    sudo tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
}

install "$TMP/pandoc-2.18-linux-amd64.tar.gz" "2" "pandoc"
install "$TMP/shellcheck-v0.8.0.linux.x86_64.tar.xz" "1" "shellcheck"
install "$TMP/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz" "1" "rg"
install "$TMP/bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz" "1" "bat"
install "$TMP/vale_2.18.0_Linux_64-bit.tar.gz" "0" "vale"
install "$TMP/delta-0.13.0-x86_64-unknown-linux-gnu.tar.gz" "1" "delta"
install "$TMP/ltex-ls-15.2.0.tar.gz" "1" "bin"
install "$TMP/ltex-ls-15.2.0.tar.gz" "1" "lib"
sudo ln --symbolic --force $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls

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
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/wordcount/wordcount.lua -o "$PANDOC_FILTER_DIR"/wordcount.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/diagram-generator/diagram-generator.lua -o "$PANDOC_FILTER_DIR"/diagram-generator.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/pagebreak/pagebreak.lua -o "$PANDOC_FILTER_DIR"/pagebreak.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/include-files/include-files.lua -o "$PANDOC_FILTER_DIR"/include-files.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/include-code-files/include-code-files.lua -o "$PANDOC_FILTER_DIR"/include-code-files.lua

# install Paq plugin manager for Neovim
git clone --depth=1 https://github.com/savq/paq-nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim
# add dictionary file so custom function does not give error
mkdir -p "$HOME"/.config/nvim/spell && touch "$HOME"/.config/nvim/spell/en.utf-8.add

# remove temp files
rm -rf $TMP

display_text "

${BOLD}Finished!${RESET}
"
