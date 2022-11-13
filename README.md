# Developer Workstation Setup Script

Welcome to your new **ultimate development environment**!

![neo-70s](./images/neo-70s.jpg)

Enjoy the same software and desktop setup regardless of which Red Hat based
distribution you choose.

## Features

- Works with Fedora 36+ and RHEL 9 compatible distributions

![rocky-fedora-logos](./images/rocky-fedora.png)

You get to choose between cutting edge Fedora or stable RHEL.

To maintain parity with Fedora 36+, any RHEL package that's not available in a
popular repository is:

1. Downloaded as a binary from GitHub or another trusted source
2. Rebuilt from a compatible SRC RPM and installed from `./el9-rebuilds`
3. Downloaded as a flatpak from [Flathub](https://flathub.org/home)

- Great software out of the box, easy to customize and choose your own

| Development                 | Browsers         | Graphics    | Sound and video | Security and backup |
| --------------------------- | ---------------- | ----------- | --------------- | ------------------- |
| Helix                       | Firefox          | Krita       | MPV             | KeepassXC           |
| Node.js / Deno              | Chromium         | Shotwell    | Handbrake       | BorgBackup          |
| Kitty (terminal)            | nnn file browser | ImageMagick | MKVToolNix      |                     |
| Lazygit (git terminal GUI)  |                  |             |                 |                     |
| GitHub CLI                  |                  |             |                 |                     |
| Pandoc (document converter) |                  |             |                 |                     |
| Shellcheck / Shfmt          |                  |             |                 |                     |
| Bat (cat replacement)       |                  |             |                 |                     |
| Ripgrep (grep replacement)  |                  |             |                 |                     |
| Delta (diff viewer)         |                  |             |                 |                     |

- Improved Gnome desktop and font settings

Gnome has been tweaked along with optional subpixel font rendering for a better
experience.

- Uses [stow](https://www.gnu.org/software/stow/) to install and mange dotfiles

All the software dotfiles are managed using stow, this makes them easy to alter
and version control on your computer.

## Installation Guide

### RHEL clones must be installed using the `workstation` option

This script is designed to be run immediately after installing the operating
system. If you are using a RHEL clone you should select `workstation` from the
software selection option during installation.

![RHEL](./images/centos-8-install-options.png)

### Use git to clone this repository

```
git clone https://github.com/David-Else/developer-workstation-setup-script
cd developer-workstation-setup-script
```

### Customize the software selection before running the script

You will want to look at the installation script and modify it with your own
preferences. This has been made as easy as possible, and should be
self-explanatory.

The following arrays in `install.sh` contain all the packages that are common to
Fedora and RHEL clones. They are set at the start of the script:

```bash
rpm_packages_to_remove=()
rpm_packages_to_install=()
flathub_packages_to_install=()
npm_global_packages_to_install=()
```

After that you can set packages to be added or removed for either RHEL clones or
Fedora:

```bash
rhel_rpm_packages_to_remove=()
rhel_rpm_packages_to_install=()
rhel_flathub_packages_to_install=()

fedora_rpm_packages_to_remove=()
fedora_rpm_packages_to_install=()
fedora_flathub_packages_to_install=()
```

Repos can be added conditionally for all OSes, so if the package is not required
then the repo is not installed:

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

### Run the scripts in the correct order

```
sudo ./install.sh
./install-binaries.bash
./setup.sh
```

Now reboot before continuing.

```
./install-rust-helix.sh
```

### Make any final changes

#### Hardware dependent

- If you have an Intel CPU with a built-in GPU then
  `sudo dnf install libva-intel-driver`, MPV will then use HW acceleration.

- If you have a 4k monitor and want to use 200% screen scaling then make it a
  default by creating the following file:

`/usr/share/glib-2.0/schemas/93_hidpi.gschema.override`

```
[org.gnome.desktop.interface]
scaling-factor=2
```

And reinit schemas with `sudo glib-compile-schemas /usr/share/glib-2.0/schemas`

If you only use the GUI `Settings/Displays` it often forgets your choice.

#### Software dependent

- Deno: create/update shell completions:

```
deno completions bash > deno.sh
sudo mv deno.sh /etc/profile.d
```

- Vale: change the global `.vale.ini` file in your `$HOME` directory to point to
  an empty directory you want to store your styles, for example:

```
StylesPath = /home/username/Documents/styles
```

and run `vale sync`. You can create a new file at
[Config Generator](https://vale.sh/generator)

#### Various

- Configure pipewire:

1. Find your sound card and available sample rates: `cat /proc/asound/cards`
   `cat /proc/asound/card[number]/stream[number]`
2. Create a user config file:
   `cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/`
3. Add your sound cards available sample rates, for example:
   `default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 ]`

- Install extra applications, for example: `pip3 install --user yt-dlp gitlint`

- Choose your default applications using the top right selection
  `Settings > Default Applications`
- Download any Gnome Extensions like `Hide Top Bar` from the
  [Gnome Extensions Website](https://extensions.gnome.org/)
- Install Firefox extensions, I recommend copy/pasting:

```
firefox https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/surfingkeys_ff/
```

- Consider increasing inotify watchers for watching large numbers of files. See
  current use with:
  `curl -s https://raw.githubusercontent.com/fatso83/dotfiles/master/utils/scripts/inotify-consumers | bash`

```
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

**ENJOY!** Please report any bugs you may encounter.

## FAQ

**Q**: How do I install Visual Studio Code?

**A**: Simply uncomment `code` from `rpm-packages-to-install` in `install.sh`
before you run it.

If you would like to use Code for things that Helix still struggles with (like
debugging), and still use all the Vim keyboard shortcuts, I suggest installing
`asvetliakov.vscode-neovim` and using these settings:

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

You might also like to install `ms-vscode.live-server` for live debugging in
Code or the browser.

**Q**: Why is the script spit into multiple parts for install and setup?

**A**: Sudo privileges are needed for the installation, and they time out before
the script can finish. This makes unattended installation impossible without
running the installer as root.

The setup part is much easier to do as a user, so running it as the user avoids
constant `su - "$SUDO_USER" -c` statements in the code. If a part of the setup
needs `sudo` it will ask for your password.

**Q**: Does this script disable the caps lock key? I've noticed that it works
during login but after that it stops working altogether.

**A**: It makes the caps lock into delete for touch typing purposes, to change
it modify this line in the setup script:

```shell
 capslock_delete="false"
```
