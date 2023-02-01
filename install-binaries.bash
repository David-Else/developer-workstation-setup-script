#!/bin/bash

set -euo pipefail
source functions.bash
confirm_user_is 'normal'

BIN_INSTALL_DIR=/usr/local/bin

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
