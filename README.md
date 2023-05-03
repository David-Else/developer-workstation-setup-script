# Developer Workstation Setup Script

Welcome to your new **ultimate development environment**!

![neo-70s](./images/neo-70s.jpg)

Enjoy the same software and desktop setup regardless of which Red Hat based distribution you choose.

- Note in v4 the Neovim config was removed and archived at: https://github.com/David-Else/neovim-config. [Helix](https://helix-editor.com/) is now used!

- Known issues with Fedora 38 are a clash with the FFMPEG rpmfusion version and the [ANSIBLE dconf module being broken in 6.5.0 that ships with f38](https://github.com/ansible-collections/community.general/pull/6206), hopefully fixed in https://github.com/ansible-collections/community.general/blob/stable-6/CHANGELOG.rst#v6-6-0 

## Features

- Works with Fedora 36+ and el9 compatible distributions

![rocky-fedora-logos](./images/rocky-fedora.png)

You get to choose between cutting edge Fedora or stable el9.

To maintain parity with Fedora 36+, any el9 package that's not available in a popular repository is:

1. Downloaded as a binary from GitHub or another trusted source
2. Rebuilt from a compatible SRC RPM and installed from `./el9-rebuilds`
3. Downloaded as a flatpak from [Flathub](https://flathub.org/home)

- Great software out of the box, easy to customize and choose your own

| Development | Browsers | Graphics | Sound and video | Security and backup |
| --- | --- | --- | --- | --- |
| Helix | Firefox | Krita | MPV | KeepassXC |
| Node.js / Deno | Chromium | Shotwell | Handbrake | BorgBackup |
| Kitty (terminal) | nnn file browser | ImageMagick | MKVToolNix |  |
| Lazygit (git terminal GUI) |  |  |  |  |
| GitHub CLI |  |  |  |  |
| Pandoc (document converter) |  |  |  |  |
| Shellcheck / Shfmt |  |  |  |  |
| Bat (cat replacement) |  |  |  |  |
| Ripgrep (grep replacement) |  |  |  |  |
| Delta (diff viewer) |  |  |  |  |

- Uses [stow](https://www.gnu.org/software/stow/) to install and mange dotfiles

All the software dotfiles are managed using stow, this makes them easy to alter and version control on your computer.

## Installation Guide

1. el9 and clones must be installed using the `workstation` option

This script is designed to be run immediately after installing the operating system. If you are using an el9 clone you should select `workstation` from the software selection option during installation.

![el9](./images/centos-8-install-options.png)

You must also give your user account administrative privileges, this is a tick-box when you are creating the user.

2. Use git to clone this repository

```sh
git clone https://github.com/David-Else/developer-workstation-setup-script
cd developer-workstation-setup-script
```

3. Customize the software selection before running the script

You will want to look at the Ansible `install.yml` and `install-setup.bash` scripts and modify them with your own software preferences.

4. Install Ansible

If you are using el9 then you need to first enable the epel repository:

```sh
# el9
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
```

Then regardless of which distribution you are using install Ansible:

```sh
sudo dnf install ansible-core ansible-collection-community-general
```

Then run the Ansible install playbook:

```sh
ansible-playbook ./install.yml -K
```

Enter your `BECOME` password, this is your user password, your account must have administrative privileges.

Then the final bash install script:

```sh
./install-setup.bash
```

### Make any final changes

#### Hardware dependent

- If you have an Intel CPU with a built-in GPU then `sudo dnf install libva-intel-driver`, MPV will then use HW acceleration.

- If you have a 4k monitor and want to use 200% screen scaling then make it a default by creating the following file:

`/usr/share/glib-2.0/schemas/93_hidpi.gschema.override`

```
[org.gnome.desktop.interface]
scaling-factor=2
```

And reinit schemas with `sudo glib-compile-schemas /usr/share/glib-2.0/schemas`

If you only use the GUI `Settings/Displays` it often forgets your choice.

#### Software dependent

- Deno: create/update shell completions:

```sh
deno completions bash > deno.sh
sudo mv deno.sh /etc/profile.d
```

- Vale: change the global `.vale.ini` file in your `$HOME` directory to point to an empty directory you want to store your styles, for example:

```sh
StylesPath = ~/Documents/styles
```

and run `vale sync`. You can create a new file at [Config Generator](https://vale.sh/generator)

#### Various

- For HEIF and AVIF image format (inc Apple `.HEIC` photos) on RHEL add `libheif-freeworld` and `heif-pixbuf-loader`

- Configure pipewire:

1. Find your sound card and available sample rates: `cat /proc/asound/cards` `cat /proc/asound/card[number]/stream[number]`
2. Create a user config file: `cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/`
3. Add your sound cards available sample rates, for example: `default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 ]`

- Configure pipewire-jack for pro-audio use:

1. Follow this guide: https://jackaudio.org/faq/linux_rt_config.html

`/etc/security/limits.d/audio.conf`
```sh
@audio   -  rtprio     95
@audio   -  memlock    unlimited
```

`sudo usermod -aG audio [username]`

2. Create a user config file: 

```sh
mkdir -p ~/.config/pipewire/jack.conf.d/
cat >~/.config/pipewire/jack.conf.d/jack.conf <<EOF
jack.properties = {
     node.latency       = 256/96000
     node.rate          = 1/96000
     node.quantum       = 256/96000
     node.force-quantum = 256
}
EOF
```

You must reboot for changes to be applied.

- Choose your default applications using the top right selection `Settings > Default Applications`
- Download any Gnome Extensions like `Hide Top Bar` from the [Gnome Extensions Website](https://extensions.gnome.org/)
- Consider increasing inotify watchers for watching large numbers of files. See current use with:

```sh
curl -s https://raw.githubusercontent.com/fatso83/dotfiles/master/utils/scripts/inotify-consumers | bash
```
Increase watchers:

```sh
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

You must run `nnn` once with `-a` to create the fifo file for the preview.

**ENJOY!** Please report any bugs you may encounter.

## FAQ

If you would like to use Code for things that Helix still struggles with (like debugging), and still use all the Vim keyboard shortcuts, I suggest installing `silverquark.dancehelix` or `asvetliakov.vscode-neovim` and using these settings:

`settings.json`

```jsonc
{
  // font size
  "editor.fontSize": 15,
  "markdown.preview.fontSize": 15,
  "terminal.integrated.fontSize": 15,
  // asvetliakov.vscode-neovim
  "editor.scrollBeyondLastLine": false,
  "vscode-neovim.neovimExecutablePaths.linux": "/usr/local/bin/nvim", // for el9 clones, or "/usr/bin/nvim" for Fedora
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

**Q**: Does this script disable the caps lock key? I've noticed that it works during login but after that it stops working altogether.

**A**: It makes the caps lock into delete for touch typing purposes, to change it modify this line in `install.yml`:

```
- { key: "/org/gnome/desktop/input-sources/xkb-options", value: "['caps:backspace', 'terminate:ctrl_alt_bksp', 'lv3:rwin_switch', 'altwin:meta_alt']" }
```
