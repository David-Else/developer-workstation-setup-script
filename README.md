# Developer Workstation Setup Script

Welcome to your new **ultimate development environment**!

![neo-70s](./images/neo-70s.jpg)![rocky-fedora-logos](./images/rocky-fedora.png)

## Features

The Developer Workstation Setup Script has the following features:

- Works with both cutting edge Fedora (tested up to 38) and stable Red Hat Enterprise Linux 9 compatible distributions.
- Easy to customize, just add and remove packages/config from the scripts before running.
- Uses [stow](https://www.gnu.org/software/stow/) to install and manage dotfiles.
- Includes a variety of development and general use software:

| Development | Browsers | Graphics | Sound and video | Security and backup |
| --- | --- | --- | --- | --- |
| Helix | Firefox | Krita | MPV | KeepassXC |
| Node.js / Deno | nnn file browser | ImageMagick | Handbrake | BorgBackup |
| Kitty |  |  | MKVToolNix |  |
| Lazygit |  |  | Blender |  |
| GitHub CLI |  |  | OBS Studio |  |
| Pandoc |  |  |  |  |
| Shellcheck / Shfmt |  |  |  |  |
| Bat |  |  |  |  |
| Ripgrep |  |  |  |  |
| Delta |  |  |  |  |

## Installation

These scripts are designed to be run immediately after installing the operating system.

![el9](./images/centos-8-install-options.png)

1. Install a fresh copy of Fedora or a Red Hat Enterprise Linux 9 compatible distribution. If you are using an el9 clone, select `workstation` from the software selection option during installation. You must also give your user account administrative privileges, this is a tick-box when you are creating the user.
2. Clone the repository and `cd` into it: `git clone https://github.com/David-Else/developer-workstation-setup-script`
3. Install Ansible:

If you are using el9, you need to first enable the epel repository:

`sudo dnf config-manager --set-enabled crb` and `sudo dnf install epel-release`.

Then install Ansible and the community collection:

`sudo dnf install ansible-core ansible-collection-community-general`

4. Customize the software selection by modifying the `install.yml` and `install-setup.bash` scripts with your own software preferences.
5. Run the scripts: `ansible-playbook ./install.yml -K` and `./install-setup.bash`

Note: Your `BECOME` password in Ansible is your user password, your account must have administrative privileges.

After installation, you must run `nnn` once with `-a` to create the fifo file for the preview feature to work.

## Optional Tweaks

Based on your software selection, hardware, and personal preferences, you may want to make the following changes:

### Audio

- Set the available sample rates for your audio interface:

1. Find your sound card and available sample rates: `cat /proc/asound/cards` `cat /proc/asound/card[number]/stream[number]`
2. Create a user config file: `cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/`
3. Add your sound cards available sample rates, for example: `default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 ]`

- Setup PipeWire for low latency audio by following the guide at https://jackaudio.org/faq/linux_rt_config.html and creating or modifying the following file:

`/etc/security/limits.d/audio.conf`
```sh
@audio   -  rtprio     95
@audio   -  memlock    unlimited
```

Add yourself to the `audio` group that you have given the privileges to with `sudo usermod -aG audio [username]`.

Create a user config file for your (PipeWire) JACK settings: 

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

### Intel CPU GPU HW acceleration

- Install the `libva-intel`(older systems) or `intel-media-driver` driver for Intel CPUs with built-in GPUs to use HW acceleration with MPV.

### General

- (el9) Fix Gnome forgetting your monitor scaling choice, if you only use the GUI `Settings/Displays` it often forgets.

Create a file `/usr/share/glib-2.0/schemas/93_hidpi.gschema.override` with the following content for 200% scaling:

```sh
[org.gnome.desktop.interface]
scaling-factor=2
```

Reinitialize schemas with `sudo glib-compile-schemas /usr/share/glib-2.0/schemas`

- Setup Deno by creating/updating shell completions: `deno completions bash > deno.sh` and `sudo mv deno.sh /etc/profile.d`.
- Setup Vale:

Change the global `.vale.ini` file in your `$HOME` directory to point to an empty directory you want to store your styles, for example:

```sh
StylesPath = ~/Documents/styles
```

Run `vale sync`. You can create a new config file at [Config Generator](https://vale.sh/generator)

- Setup HEIF and AVIF image formats (inc Apple `.HEIC` photos) by adding `libheif-freeworld` and `heif-pixbuf-loader`.

# FAQ

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

```yml
- { key: "/org/gnome/desktop/input-sources/xkb-options", value: "['caps:backspace', 'terminate:ctrl_alt_bksp', 'lv3:rwin_switch', 'altwin:meta_alt']" }
```
