#!/bin/bash

GREEN="\e[38;5;46m"
RESET="\e[0m"

set -euo pipefail
source functions.bash
confirm_user_is 'normal'
sudo --validate

BIN_INSTALL_DIR=/usr/local/bin
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

download 2022-12-28 artempyanykh/marksman "*linux"
download v3.6.0 mvdan/sh "*linux_amd64"
download 13.0.0 BurntSushi/ripgrep "*x86_64-unknown-linux-musl.tar.gz"
download v2.21.3 errata-ai/vale "*Linux_64-bit.tar.gz"
download 15.2.0 valentjn/ltex-ls "*ltex-ls-15.2.0.tar.gz"
download 0.15.1 dandavison/delta "*x86_64-unknown-linux-musl.tar.gz"

install "ripgrep*" 1 rg
install "vale*" 0 vale
install "delta*" 1 delta
install "ltex*" 1 bin
install "ltex*" 1 lib
sudo ln --symbolic --force $BIN_INSTALL_DIR/bin/ltex-ls $BIN_INSTALL_DIR/ltex-ls

# marksman
chmod +x "$TMP/marksman-linux"
sudo cp -i "$TMP/marksman-linux" $BIN_INSTALL_DIR/marksman

# shfmt
chmod +x "$TMP/shfmt_v3.6.0_linux_amd64"
sudo cp -i "$TMP/shfmt_v3.6.0_linux_amd64" $BIN_INSTALL_DIR/shfmt

# deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# tt
sudo curl -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt-linux -o $BIN_INSTALL_DIR/tt && sudo chmod +x $BIN_INSTALL_DIR/tt
sudo curl -o /usr/share/man/man1/tt.1.gz -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt.1.gz

# rust and rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup component add rust-analyzer

# symlink rust-analyzer executable, won't be needed after https://github.com/rust-lang/rustup/pull/3022
[ ! -e /usr/local/bin/rust-analyzer ] && sudo ln -s $(rustup which rust-analyzer) /usr/local/bin/rust-analyzer

# remove temp files
rm -rf $TMP
