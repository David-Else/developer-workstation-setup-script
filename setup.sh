#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

if [ "$(id -u)" = 0 ]; then
    echo "You're root! Run script as user" && exit 1
fi

# Call with arguments (path, line to add)
function add_to_file() {
    touch "$1"
    grep -qxF "$2" "$1" && echo "$2 exists in ${GREEN}$1${RESET}" || echo "$2" >>"$1"
}

#==============================================================================
# Set host name
#==============================================================================
clear
read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# Gnome desktop settings
#==============================================================================
idle_delay=2400
title_bar_buttons_on="true"
clock_show_date="true"
capslock_delete="true"
night_light="true"

gsettings set org.gnome.desktop.session \
    idle-delay $idle_delay

if [[ "${title_bar_buttons_on}" == "true" ]]; then
    gsettings set org.gnome.desktop.wm.preferences \
        button-layout 'appmenu:minimize,maximize,close'
fi

if [[ "${clock_show_date}" == "true" ]]; then
    gsettings set org.gnome.desktop.interface \
        clock-show-date true
fi

if [[ "${capslock_delete}" == "true" ]]; then
    gsettings set org.gnome.desktop.input-sources \
        xkb-options "['caps:backspace', 'terminate:ctrl_alt_bksp']"
fi

if [[ "${night_light}" == "true" ]]; then
    gsettings set org.gnome.settings-daemon.plugins.color \
        night-light-enabled true
fi

#==============================================================================
# Font settings for sub-pixel rendering
#==============================================================================
read -p "Use sub-pixel rendering? (recommended for monitors with less than 4k resolution) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    add_to_file "$HOME/.Xresources" "Xft.lcdfilter: lcddefault"
    dconf write /org/gnome/settings-daemon/plugins/xsettings/antialiasing "'rgba'"
    echo "Sub-pixel rendering set, see tweaks and $HOME/.Xresources"
fi

#==============================================================================
# Move dotfiles to the home directory, backup existing files and run stow
#==============================================================================
mv ./dotfiles ~/dotfiles

mv "$HOME/.bash_profile" "$HOME/.bash_profile_backup"
mv "$HOME/.bashrc" "$HOME/.bashrc_backup"

cd "$HOME/dotfiles" || exit
stow *
cd - || exit

#==============================================================================
# Increase inotify watchers for watching large numbers of files, default is 8192
#
# curl -s https://raw.githubusercontent.com/fatso83/dotfiles/master/utils/scripts/inotify-consumers | bash
#==============================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Creae directory for neovim plugins
mkdir -p "$HOME"/.config/nvim/plugged

cat <<EOL

===============================================================================
Congratulations, you are set up! Further suggested changes are:

Gnome:    settings  > details > choose default applications
          network   > wired   > connect automatically
          software  > install 'Hide Top Bar'

${GREEN}flatpak run org.mozilla.firefox${RESET} (RHEL) or ${GREEN}firefox

https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/surfingkeys_ff/${RESET}

Firefox:  Preferences > Network Settings > Enable DNS over HTTPS
          about:config network.security.esni.enabled
          (test with https://www.cloudflare.com/ssl/encrypted-sni/)

          Privacy & Security > HTTPS-Only Mode > Enable HTTPS-Only Mode in all windows

ytfzf: Helps you find Youtube videos (without API) and opens/downloads them using mpv/youtube-dl
------------------------------------------------------------------------------------------------
${GREEN}git clone https://github.com/pystardust/ytfzf${RESET}
${GREEN}cd ytfzf${RESET}
${GREEN}sudo make install${RESET}

Fix Visual Studio Code keyboard input on RHEL 8 and clones
------------------------------------------------------
- Uncomment code="GTK_IM_MODULE=ibus code" from .bashrc
- Go to terminal type 'ibus-setup'
- Go to Emoji tab, press the '...' next to Emoji choice to get 'select keyboard shortcut for switching' window
- Use the delete button to delete the shortcut and leave nothing there, press OK
- Close

Improve audio on RHEL 8 and clones (not needed with Fedora 34 and pipewire)
---------------------------------------------------------------------------
${GREEN}sudo sed -i "s/; default-sample-format = s16le/default-sample-format = s32le/g" /etc/pulse/daemon.conf${RESET}
${GREEN}sudo sed -i "s/; resample-method = speex-float-1/resample-method = speex-float-10/g" /etc/pulse/daemon.conf${RESET}
${GREEN}sudo sed -i "s/; avoid-resampling = false/avoid-resampling = true/g" /etc/pulse/daemon.conf${RESET}

Setup Neovim desktop integration and icons
------------------------------------------
${GREEN}xdg-desktop-menu install --novendor ./nvim.desktop${RESET}
${GREEN}xdg-icon-resource install --novendor --mode user --size 64 ./nvim.png${RESET}
${GREEN}sudo ln -s ~/.config/nvim/plugged/fzf/bin/fzf /usr/local/bin${RESET}
double click on codicon.ttf (copy and paste from https://raw.githubusercontent.com/microsoft/vscode-codicons/main/dist/codicon.csv)

Create/update Deno completions
------------------------------
${GREEN}deno completions bash > deno.sh${RESET}
${GREEN}sudo mv deno.sh /etc/profile.d${RESET}

Please reboot (or things may not work as expected)
===============================================================================
EOL
