#!/bin/bash

# note:  run this script after setup.sh as the rust installer adds to .bashrc
#        see https://copr.fedorainfracloud.org/coprs/varlad/helix/ for compiled releases

set -e # quit on error
source functions.bash

SOURCE_DIR=~/src/helix # directory to store helix source, user changeable
CONFIG_DIR=~/.config/helix
CONFIG_FILE="$CONFIG_DIR/config.toml"
LANG_FILE="$CONFIG_DIR/languages.toml"

# install the latest rust and rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-analyzer # TEST TEST TEST maybe need to source bashrc

# symlink rust-analyzer executable, won't be needed after https://github.com/rust-lang/rustup/pull/3022
sudo ln -s $(rustup which rust-analyzer) /usr/local/bin/rust-analyzer

# install helix from source and compile
mkdir -p $SOURCE_DIR
cd $SOURCE_DIR || exit
git clone https://github.com/helix-editor/helix
git checkout 0dbee9590baed10bef3c6c32420b8a5802204657 # hand picked stable point
cargo install --path helix-term

# create the config files
stow --verbose --dir="$HOME/.dotfiles" --target="$HOME" helix
cd $CONFIG_DIR || exit
[ ! -e ./runtime ] && ln -s $SOURCE_DIR/runtime . # if there is no symlink create one to the source directory

# add desktop files
cp contrib/Helix.desktop ~/.local/share/applications
cp contrib/helix.png ~/.local/share/icons
sed -i "s|Exec=hx %F|Exec=kitty hx %F|g" ~/.local/share/applications/Helix.desktop
sed -i "s|Terminal=true|Terminal=false|g" ~/.local/share/applications/Helix.desktop

display_text "
${BOLD}Finished!${RESET}

Helix has been installed and compiled from source

- Don't delete the source directory: $SOURCE_DIR
- Make configuration changes in: $CONFIG_DIR/
- Update with:

cd $SOURCE_DIR
git pull
cargo install --path helix-term

"
