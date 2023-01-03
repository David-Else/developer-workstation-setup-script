#!/bin/bash

# note:  run after setup.sh as the rust installer adds to .bashrc and you need stow files it created
#        see https://copr.fedorainfracloud.org/coprs/varlad/helix/ for compiled releases

set -e # quit on error
source functions.bash

SOURCE_DIR=~/src/helix # helix source code directory
TERMINAL=kitty         # terminal program to use for desktop integration

# install the latest rust and rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup component add rust-analyzer

# symlink rust-analyzer executable, won't be needed after https://github.com/rust-lang/rustup/pull/3022
[ ! -e /usr/local/bin/rust-analyzer ] && sudo ln -s $(rustup which rust-analyzer) /usr/local/bin/rust-analyzer

# install helix from source and compile
mkdir -p $SOURCE_DIR
git clone https://github.com/helix-editor/helix $SOURCE_DIR
cd $SOURCE_DIR || exit
git checkout 0dbee9590baed10bef3c6c32420b8a5802204657 # hand picked stable point
cargo install --path helix-term

# add desktop files
cp contrib/Helix.desktop ~/.local/share/applications
cp contrib/helix.png ~/.local/share/icons
sed -i "s|Exec=hx %F|Exec=$TERMINAL hx %F|g" ~/.local/share/applications/Helix.desktop
sed -i "s|Terminal=true|Terminal=false|g" ~/.local/share/applications/Helix.desktop

# create the config files
stow --verbose --dir="$HOME/.dotfiles" --target="$HOME" helix
cd ~/.config/helix || exit
[ ! -e ./runtime ] && ln -s $SOURCE_DIR/runtime . # if there is no symlink create one to the source directory

display_text "
${BOLD}Finished!${RESET}

Helix has been installed and compiled from source

- Don't delete the source directory: $SOURCE_DIR
- Update with:

cd $SOURCE_DIR
git pull
cargo install --path helix-term

"