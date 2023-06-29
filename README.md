# Developer Workstation Setup Script Debian 12 Edition

Test version for Debian 12.

## Installation

These scripts are designed to be run immediately after installing the operating system.

1. Install a fresh copy of Debian 12. Don't fill in any details for the root account and make your user have admin/sudo rights.
2. Install Ansible and git: `sudo apt install ansible git`
3. Clone the repository and `cd` into it: `git clone https://github.com/David-Else/developer-workstation-setup-script`
4. Customize the software selection by modifying the `install.yml` and `install-setup.bash` scripts with your own software preferences.
5. Run the scripts: `ansible-playbook ./install.yml -K` and `./install-setup.bash`

Note: Your `BECOME` password in Ansible is your user password, your account must have administrative privileges.

After installation, you must run `nnn` once with `-a` to create the fifo file for the preview feature to work.

## Optional Tweaks

Based on your software selection, hardware, and personal preferences, you may want to make the following changes:

### Audio

- Set the available sample rates for your audio interface:

1. Find your audio interface(s) and available sample rates:

`cat /proc/asound/cards`

Example output:

```sh
 0 [HDMI           ]: HDA-Intel - HDA ATI HDMI
                      HDA ATI HDMI at 0xf7e60000 irq 31
 1 [USB            ]: USB-Audio - Scarlett 6i6 USB
                      Focusrite Scarlett 6i6 USB at usb-0000:00:14.0-10, high speed
```

Play some audio and examine the stream for your audio interface (in this case `card1`):

`cat /proc/asound/card1/stream0`

Example output:

```sh
Focusrite Scarlett 6i6 USB at usb-0000:00:14.0-10, high speed : USB Audio

Playback:
  Status: Running
    Interface = 1
    Altset = 1
    Packet Size = 216
    Momentary freq = 48000 Hz (0x6.0000)
    Feedback Format = 16.16
  Interface 1
    Altset 1
    Format: S32_LE
    Channels: 6
    Endpoint: 0x01 (1 OUT) (ASYNC)
    Rates: 44100, 48000, 88200, 96000, 176400, 192000
    Data packet interval: 125 us
    Bits: 24
    Channel map: FL FR FC LFE RL RR
    Sync Endpoint: 0x81 (1 IN)
    Sync EP Interface: 1
    Sync EP Altset: 1
    Implicit Feedback Mode: No
```

2. Create a PipeWire user config file: `cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/`
3. Add/modify your sound cards available sample rates by editing `~/.config/pipewire/pipewire.conf`:

The Fedora default is:

```sh
#default.clock.allowed-rates = [ 48000 ]
```

For the Scarlett 6i6 example above replace it with:

```sh
default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 ]
```

Don't forget to remove the `#` comment.

- Setup PipeWire for low latency audio by following the guide at https://jackaudio.org/faq/linux_rt_config.html and creating the following file:

Note: Copy code blocks by clicking on the top right-hand corner, then just paste them into your terminal.

```sh
cat <<'EOF' | sudo tee /etc/security/limits.d/audio.conf
@audio   -  rtprio     95
@audio   -  memlock    unlimited
EOF
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

### General

- Setup Deno by creating/updating shell completions: `deno completions bash > deno.sh` and `sudo mv deno.sh /etc/profile.d`.
- Setup Vale:

Change the global `.vale.ini` file in your `$HOME` directory to point to an empty directory you want to store your styles, for example:

```sh
StylesPath = ~/Documents/styles
```

Run `vale sync`. You can create a new config file at [Config Generator](https://vale.sh/generator)

- Setup Git:

```sh
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

```sh
git config --global user.signingkey key
git config --global commit.gpgsign true
```

# FAQ

If you would like to use Code for things that Helix still struggles with (like debugging), and still use all the modal keyboard shortcuts, I suggest installing `silverquark.dancehelix` or `asvetliakov.vscode-neovim` and using these settings:

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
- {
    key: "/org/gnome/desktop/input-sources/xkb-options",
    value: "['caps:backspace', 'terminate:ctrl_alt_bksp', 'lv3:rwin_switch', 'altwin:meta_alt']",
  }
```
