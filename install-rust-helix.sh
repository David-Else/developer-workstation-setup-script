#!/bin/bash

# this script should be ran last after setup as the rust install alters .bashrc

set -e # quit on error
source functions.bash

# install the latest rust and rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-analyzer # TEST TEST TEST maybe need to source bashrc
sudo ln -s $(rustup which rust-analyzer) /usr/local/bin/rust-analyzer

# install helix from source and compile
SOURCE_DIR=~/src/helix                # directory to store helix source, user changeable
CONFIG_DIR=~/.config/helix            # default, don't change
CONFIG_FILE="$CONFIG_DIR/config.toml" # default, don't change
LANG_FILE="$CONFIG_DIR/languages.toml"

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

if [ ! -f $LANG_FILE ]; then
    cat >$LANG_FILE <<EOF
[[language]]
name = "html"
formatter = { command = 'prettier', args = ["--parser", "html"] }

[[language]]
name = "css"
formatter = { command = 'prettier', args = ["--parser", "css"] }

[[language]]
name = "markdown"
# language-server = { command = "ltex-ls" }
# formatter = { command = 'prettier', args = ["--parser", "markdown"] }
formatter = { command = 'prettier', args = [
  "--parser",
  "markdown",
  "--prose-wrap",
  "always",
] }
auto-format = true

[[language]]
name = "bash"
formatter = { command = 'shfmt', args = ["-i", "4"] }
auto-format = true

[[language]]
name = "rust"
[language.config]
checkOnSave = { command = "clippy" }

[[language]]
name = "json"
formatter = { command = 'deno', args = ["fmt", "-", "--ext", "json"] }

[[language]]
name = "javascript"
formatter = { command = 'deno', args = ["fmt", "-", "--ext", "js"] }
auto-format = true

[[language]]
name = "typescript"
formatter = { command = 'deno', args = ["fmt", "-", "--ext", "ts"] }
auto-format = true

[[language]]
name = "jsx"
formatter = { command = 'deno', args = ["fmt", "-", "--ext", "jsx"] }
auto-format = true

[[language]]
name = "tsx"
formatter = { command = 'deno', args = ["fmt", "-", "--ext", "tsx"] }
auto-format = true
EOF
    echo "
    $LANG_FILE created"
else
    echo "
    $LANG_FILE exists, skipping creating new one"
fi

display_text "
${BOLD}Finished!${RESET}

Helix has been installed and compiled from source

- Don't delete the source directory: $SOURCE_DIR
- Make configuration changes in: $CONFIG_DIR/
- Update with:

cd $SOURCE_DIR
git pull
cargo install --path helix-term

GitHub binaries have been installed to ${GREEN}${BIN_INSTALL_DIR}${RESET}
Pandoc filters have been installed to ${GREEN}${PANDOC_FILTER_DIR}${RESET}

"
