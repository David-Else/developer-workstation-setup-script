#!/bin/bash

# this script should be ran last after setup as the rust install alters .bashrc

set -e # quit on error
source functions.bash

# install the latest rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install helix from source and compile
SOURCE_DIR=~/src/helix                # directory to store helix source, user changeable
CONFIG_DIR=~/.config/helix            # default, don't change
CONFIG_FILE="$CONFIG_DIR/config.toml" # default, don't change

mkdir -p $SOURCE_DIR
git clone https://github.com/helix-editor/helix $SOURCE_DIR
cd $SOURCE_DIR || exit
cargo install --path helix-term

mkdir -p $CONFIG_DIR
cd $CONFIG_DIR || exit
[ ! -e ./runtime ] && ln -s $SOURCE_DIR/runtime . # if there is no symlink create one to the source directory

if [ ! -f $CONFIG_FILE ]; then # if there is no config file create one
    cat >$CONFIG_FILE <<EOF
theme = "dark_plus"

[keys.normal]
G = "goto_file_end" # vim
Z = { Z = ":wq", Q = ":q!" } # vim, save and quit, quit without saving
"#" = "toggle_comments"
C-s = ":w"

[keys.insert]
j = { k = "normal_mode" }
C-s = ":w"

[keys.select]
G = "goto_file_end" # vim

[editor.cursor-shape]
insert = "bar" # change cursor shape in insert mode

[editor.file-picker]
hidden = false # don't ignore hidden files
EOF
    echo "
    $CONFIG_FILE created"
else
    echo "
    $CONFIG_FILE exists, skipping creating new one"
fi

display_text "
${BOLD}Finished!${RESET}

Helix has been installed and compiled from source

- Don't delete the source directory: $SOURCE_DIR
- Make configuration changes in: $CONFIG_DIR/config.toml
- Update with:

cd $SOURCE_DIR
git pull
cargo install --path helix-term

GitHub binaries have been installed to ${GREEN}${BIN_INSTALL_DIR}${RESET}
Pandoc filters have been installed to ${GREEN}${PANDOC_FILTER_DIR}${RESET}

"
