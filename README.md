# Developer Workstation Setup Script

![neo-70s](./images/neo-70s.jpg)

Welcome to your new **ultimate development environment**! A post-install setup script for developers that works on Fedora and all RHEL 8 clones. Enjoy the same software and desktop regardless of which Red Hat based distribution you choose.

## Features

### Fedora 34+ and RHEL 8+ clones compatibility

![rocky-fedora-logos](./images/rocky-fedora.png)

Works across Fedora 34+, RHEL 8+ and all clones. You get to choose between cutting edge Fedora or stable RHEL clones. I suggest if you want stable, then choose Rocky.

To maintain parity with Fedora 34+, any package that's not available directly in RHEL is downloaded as:

- A binary from GitHub or another trusted source
- From [flathub](https://flathub.org/home)

### Great software out of the box, easy to customize and choose your own

| Development    | Browsers         | Graphics    | Sound and video | Security and backup |
| -------------- | ---------------- | ----------- | --------------- | ------------------- |
| Neovim         | Firefox          | Krita       | MPV             | KeepassXC           |
| Node.js / Deno | Chromium         | Shotwell    | Handbrake       | BorgBackup          |
| Gnome Boxes    | nnn file browser | ImageMagick | MKVToolNix      |                     |
| Lazygit        |                  |             |                 |                     |
| GitHub CLI     |                  |             |                 |                     |
| Pandoc         |                  |             |                 |                     |
| Shellcheck     |                  |             |                 |                     |
| Shfmt          |                  |             |                 |                     |
| Bat            |                  |             |                 |                     |
| Ripgrep        |                  |             |                 |                     |
| Vale           |                  |             |                 |                     |

### Improved Gnome desktop and font settings

Gnome has been tweaked along with font settings for a better experience.

### Neovim 0.6 with plugins and custom keybindings

Setup out of the box with the latest [Neovim 0.6](https://neovim.io) and plugins configured to use `fzf`, `ripgrep` and `bat` with an attractive Visual Studio Code theme

![Neovim](./images/neo-vim-with-vs-code-theme-preview.png)

### Uses [stow](https://www.gnu.org/software/stow/) to install and mange dotfiles

All the software dotfiles are managed using stow, this makes them easy to alter and version on your computer.

## Installation

### RHEL clones must be installed using the `workstation` option

This script is designed to be run immediately after installing the operating system. If you are using a RHEL clone you should select `workstation` from the software selection option during installation.

![RHEL](./images/centos-8-install-options.png)

### Use git to clone this repository

```
git clone https://github.com/David-Else/developer-workstation-setup-script
cd developer-workstation-setup-script
```

### Customize the software selection before running the script

You will want to look at the installation script and modify it with your own preferences. This has been made as easy as possible, and should be self-explanatory.

The following arrays in `install.sh` contain all the packages that are common to Fedora and RHEL clones. They are set at the start of the script:

```bash
rpm_packages_to_remove=()
rpm_packages_to_install=()
flathub_packages_to_install=()
npm_global_packages_to_install=()
```

Inside a `if then` conditional these arrays are modified depending on if you have installed Fedora or a RHEL clone.

```bash
detect_os

if [[ "$OS" == "valid_rhel" ]]; then

    add_redhat_repositories() {}

    add_redhat_repositories
    rpm_packages_to_remove+=("${rhel_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${rhel_rpm_packages_to_install[@]}")
    flathub_packages_to_install+=("${rhel_flathub_packages_to_install[@]}")

elif [ "$OS" == "valid_fedora" ]; then

    add_fedora_repositories() {}

    add_fedora_repositories
    rpm_packages_to_remove+=("${fedora_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${fedora_rpm_packages_to_install[@]}")

else
    echo "Unsupported OS or version" && exit 1
fi
```

Repos can be added conditionally for all OSes, so if the package is not required then the repo is not installed:

```bash
    case " ${rpm_packages_to_install[*]} " in
    *' code '*)
        rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        ;;&
    *' lazygit '*)
        dnf -y copr enable atim/lazygit
        ;;&
    *' gh '*)
        dnf -y config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        ;;
    esac
```

### Run the scripts

```
sudo ./install.sh
sudo ./install-github-binaries.bash
./setup.sh
```

**ENJOY!**

## Neovim keybindings and plugins used

### Neovim custom key mappings

```
General                                     LSP
-------                                     ---
         jk = escape                        gD        = jumps to the declaration
     ctrl-s = save                          gd        = jumps to the definition
alt h/j/k/l = navigate windows              K         = displays hover information
                                            ctrl-k    = displays signature info
<leader>ts = open terminal below            gi        = lists all implementations
<leader>tv = open terminal to the right                 in the quickfix window
                                            gr        = list all symbol references
<leader>cd = working dir to current file    <space>wa = add workspace folder
<leader>qa = quit all                       <space>wr = remove workstation folder
<leader>cc = toggle colorcolumn             <space>wl = list workstation folders
<leader>n  = toggle line numbers            <space>D  = jump to type definition
<leader>w  = toggle whitespaces             <space>f  = format
<leader>z  = toggle zen mode                <space>rn = rename all symbol references
                                            <space>ca = selects a code action
                                            <space>e  = show diagnostics from line
                                            <space>q  = sets the location list
                                            [d        = move to previous diagnostic
                                            ]d        = move to next diagnostic


fzf.vim                                     Tree-sitter
-------                                     -----------
ctrl-p     = open file explorer             <CR>    = Initilize selection
<leader>b  = open buffers                   <CR>    = Expand selection by scope
<leader>h  = open file history              <TAB>   = Expand selection by node
<leader>rg = ripgrep search results         <S-TAB> = Shrink selection by node
<leader>gs = git status
<leader>gh = git commits history
ctrl-/     = toggle preview window
ctrl-t/x/v = open in new tab/split/vert split


trouble.nvim                                vim-commentary
------------                                --------------
<leader>xx = toggle                         gcc = comment out a line (takes a count)
<leader>xw = toggle workspace diagnostics   gc  = comment out the target of a motion,
<leader>xd = toggle document diagnostics          or the selection in visual mode
<leader>xq = toggle quickfix
<leader>xl = toggle loclist
        gR = toggle lsp references
```

For all the Vim/Neovim built in shortcuts please check out https://www.elsewebdevelopment.com/ultimate-vim-keyboard-shortcuts/

### Neovim plugins

This is a list of all the plugins used, please follow the links to read about how to operate them.

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Nvim Treesitter configurations and abstraction layer
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - Quickstart configurations for the Nvim LSP client
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp/) - Auto completion plugin for nvim written in Lua
- [nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb) - Shows a lightbulb whenever a `textDocument/codeAction` is available at the current cursor position
- [nvim-markdown-preview](https://github.com/davidgranstrom/nvim-markdown-preview) - Markdown preview in the browser using pandoc/live-server through Neovim's job-control API
- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) - Distraction-free coding for Neovim
- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) - Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua

- [vim-commentary](https://github.com/tpope/vim-commentary) - Comment stuff out
- [fzf.vim](https://github.com/junegunn/fzf.vim) - fzf vim wrapper

## FAQ

**Q**: How do I install Visual Studio Code?

**A**: Simply uncomment `code` from `rpm-packages-to-install` in `install.sh` before you run it.

If you would like to use Code for things that Neovim still struggles with (like debugging), and still use all the Vim keyboard shortcuts, I suggest installing `asvetliakov.vscode-neovim` and using these settings:

`settings.json`

```jsonc
{
  // font size
  "editor.fontSize": 15,
  "markdown.preview.fontSize": 15,
  "terminal.integrated.fontSize": 15,
  // asvetliakov.vscode-neovim
  "editor.scrollBeyondLastLine": false,
  "vscode-neovim.neovimExecutablePaths.linux": "/usr/local/bin/nvim", // for RHEL clones, or "/usr/bin/nvim" for Fedora
  "workbench.list.automaticKeyboardNavigation": false,
  // various
  "window.titleBarStyle": "custom", // adjust the appearance of the window title bar for linux
  "editor.minimap.enabled": false, // controls whether the minimap is shown
  "workbench.activityBar.visible": false, // controls the visibility of the activity bar in the workbench
  "window.menuBarVisibility": "hidden", // control the visibility of the menu bar
  "files.restoreUndoStack": false, // don't restore the undo stack when a file is reopened
  "editor.dragAndDrop": false, // controls whether the editor should allow moving selections via drag and drop
  "telemetry.enableTelemetry": false // disable diagnostic data collection
}
```

You might also like to install `ms-vscode.live-server` for live debugging in Code or the browser.

**Q**: Why is the script spit into two parts for install and setup?

**A**: Sudo privileges are needed for the installation, and they time out before the script can finish. This makes unattended installation impossible without running the installer as root.

The setup part is much easier to do as a user, so running it as the user avoids constant `su - "$SUDO_USER" -c` statements in the code. If a part of the setup needs `sudo` it will ask for your password.

**Q**: Does this script disable the caps lock key? I've noticed that it works during login but after that it stops working altogether.

**A**: It makes the caps lock into delete for touch typing purposes, to change it modify this line in the setup script:

```shell
 capslock_delete="false"
```
