#!/bin/bash
set -euo pipefail
sudo --validate
source colors.bash
source functions.bash
confirm_user_is 'normal'

BIN_INSTALL_DIR=/usr/local/bin
PANDOC_FILTER_DIR="$HOME"/.local/share/pandoc/filters

##############################################################
# Download
##############################################################

# ${1} repo ${2} regex pattern
download_gh() {
    echo -e "Downloading ${GREEN}${1}${RESET}..."
    # --dir "./" should be default
    gh release download --repo "$1" --pattern "$2"
}

PANDOC_FILENAME=pandoc-2.17.1.1-linux-amd64.tar.gz
SHELLCHECK_FILENAME=shellcheck-v0.8.0.linux.x86_64.tar.xz
SHFMT_FILENAME=shfmt_v3.4.3_linux_amd64
RIPGREP_FILENAME=ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz
BAT_FILENAME=bat-v0.20.0-x86_64-unknown-linux-musl.tar.gz
VALE_FILENAME=vale_2.15.4_Linux_64-bit.tar.gz
LTEXLS_FILENAME=ltex-ls-15.2.0.tar.gz
DELTA_FILENAME=delta-0.13.0-x86_64-unknown-linux-gnu.tar.gz

echo -e "${BOLD}Installing GitHub binaries${RESET}"

download_gh jgm/pandoc -p $PANDOC_FILENAME
download_gh koalaman/shellcheck -p $SHELLCHECK_FILENAME
download_gh mvdan/sh -p $SHFMT_FILENAME
download_gh BurntSushi/ripgrep -p $RIPGREP_FILENAME
download_gh sharkdp/bat -p $BAT_FILENAME
download_gh errata-ai/vale -p $VALE_FILENAME
download_gh valentjn/ltex-ls -p $LTEXLS_FILENAME
download_gh dandavison/delta -p $DELTA_FILENAME

git clone --depth=1 https://github.com/savq/paq-nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim
git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME"/bin/.fzf
git clone -b v2.3 https://github.com/pystardust/ytfzf
##############################################################
# install
##############################################################

# Extracts a file from a tar archieve into a directory
# ${1} filename ${2} strip ${3} newname
install() {
    if [ -f "$BIN_INSTALL_DIR"/"$3" ]; then
        echo -e "${GREEN}$3${RESET} was previously installed, updating to new version"
    fi
    sudo tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
}

install "$PANDOC_FILENAME" "2" "pandoc"
install "$SHELLCHECK_FILENAME" "1" "shellcheck"
install "$RIPGREP_FILENAME" "1" "rg"
install "$BAT_FILENAME" "1" "bat"
install "$VALE_FILENAME" "0" "vale"
install "$DELTA_FILENAME" "1" "delta"

# install ltex-ls
sudo tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf $LTEXLS_FILENAME --no-anchored 'bin' --strip=1
sudo tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf $LTEXLS_FILENAME --no-anchored 'lib' --strip=1
sudo ln --symbolic --force $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls

# install Paq plugin manager for Neovim, add dictionary file so custom function does not give error
mkdir -p "$HOME"/.config/nvim/spell
touch "$HOME"/.config/nvim/spell/en.utf-8.add

# install fzf
"$HOME"/bin/.fzf/install

# install shfmt
chmod +x $SHFMT_FILENAME
sudo cp -i $SHFMT_FILENAME $BIN_INSTALL_DIR/shfmt

# install ytfzf
cd ytfzf || exit 1
sudo make install doc
cd ..

# download and install deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# download and install kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln --symbolic --force ~/.local/kitty.app/bin/kitty $BIN_INSTALL_DIR
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop

# download and install nnn plugins
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

# download and install pandoc filters
mkdir -p "$PANDOC_FILTER_DIR"
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/wordcount/wordcount.lua -o "$PANDOC_FILTER_DIR"/wordcount.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/diagram-generator/diagram-generator.lua -o "$PANDOC_FILTER_DIR"/diagram-generator.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/pagebreak/pagebreak.lua -o "$PANDOC_FILTER_DIR"/pagebreak.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/include-files/include-files.lua -o "$PANDOC_FILTER_DIR"/include-files.lua
curl https://raw.githubusercontent.com/pandoc/lua-filters/master/include-code-files/include-code-files.lua -o "$PANDOC_FILTER_DIR"/include-code-files.lua

##############################################################
# cleanup
##############################################################

compgen -A variable -X '!*_FILENAME*' | while read line; do rm "${!line}"; done
rm -rf ./ytfzf

##############################################################
# display user message
##############################################################

display_text "

${BOLD}Finished!${RESET}

Now install the setup with ${GREEN}./setup.sh${RESET}...

"
