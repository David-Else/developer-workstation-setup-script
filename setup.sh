#!/bin/bash

set -eo pipefail

source functions.bash
source colors.bash

idle_delay=2400
title_bar_buttons_on="true"
clock_show_date="true"
capslock_delete="true"
night_light="true"

confirm_user_is 'normal'
detect_os
clear

#==============================================================================
# Improve pulse audio on RHEL clones, not needed on Fedora which uses pipewire
#==============================================================================
if [[ "$OS" == "valid_rhel" ]]; then
    sudo sed -i "s/; default-sample-format = s16le/default-sample-format = s32le/g" /etc/pulse/daemon.conf
    sudo sed -i "s/; resample-method = speex-float-1/resample-method = speex-float-10/g" /etc/pulse/daemon.conf
    sudo sed -i "s/; avoid-resampling = false/avoid-resampling = true/g" /etc/pulse/daemon.conf
fi

#==============================================================================
# Set host name
#==============================================================================
read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# Gnome desktop settings
#==============================================================================
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
    echo "Sub-pixel rendering on"
fi

#==============================================================================
# Backup files, move new dotfiles to the home directory and run stow
#==============================================================================
mv "$HOME/.bash_profile" "$HOME/.bash_profile_backup"
mv "$HOME/.bashrc" "$HOME/.bashrc_backup"

#! TEST !
if [[ -d "$HOME/dotfiles" ]]; then
    read -p "You have a dotfiles directory, shall I unstow/delete and replace with the new one? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        stow -D --verbose --dir="$HOME/dotfiles" */
        rm -rf "$HOME/dotfiles"
    fi
fi

mv ./dotfiles "$HOME/dotfiles"
stow --verbose --dir="$HOME/dotfiles" */

#==============================================================================
# Increase inotify watchers for watching large numbers of files, default is 8192
#
# curl -s https://raw.githubusercontent.com/fatso83/dotfiles/master/utils/scripts/inotify-consumers | bash
#==============================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

#==============================================================================
# Enable magic SysRq key / RightAlt+PrtScn+
#
#  Reboot  :R: Switch to XLATE mode
#  Even    :E: Send terminate signal to all processes except init
#  If      :I: Send kill signal to all processes except init
#  System  :S: Sync all mounted file-systems
#  Utterly :U: Remount file-systems as read-only
#  Broken  :B: Reboot
#==============================================================================
sudo grep -qxF "kernel.sysrq = 1" "/etc/sysctl.d/90-sysrq.conf" &&
    echo "kernel.sysrq = 1 exists in ${GREEN}/etc/sysctl.d/90-sysrq.conf${RESET}" ||
    echo "kernel.sysrq = 1" >>"/etc/sysctl.d/90-sysrq.conf"

display_text "

${BOLD}Congratulations, everything is installed!${RESET}

===============================================================================
Further suggested changes are:

Gnome:    settings  > details > choose default applications
          software  > install 'Hide Top Bar'

${GREEN}flatpak run org.mozilla.firefox${RESET} (RHEL) or ${GREEN}firefox

https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/surfingkeys_ff/${RESET}

Firefox:  Preferences > Network Settings > Enable DNS over HTTPS
          about:config network.security.esni.enabled
          (test with https://www.cloudflare.com/ssl/encrypted-sni/)

          Privacy & Security > HTTPS-Only Mode > Enable HTTPS-Only Mode in all windows

Fix Visual Studio Code keyboard input on RHEL 8 and clones
------------------------------------------------------
- Un-comment ${GREEN}code="GTK_IM_MODULE=ibus code"${RESET} from ${GREEN}.bashrc${RESET}
- Go to terminal type 'ibus-setup'
- Go to Emoji tab, press the '...' next to Emoji choice to get 'select keyboard shortcut for switching' window
- Use the delete button to delete the shortcut and leave nothing there, press OK
- Close

Setup fzf (after Neovim plugin has been installed) and vale 
-----------------------------------------------------------
${GREEN}sudo ln -s ~/.config/nvim/plugged/fzf/bin/fzf /usr/local/bin${RESET}

change the ${GREEN}~/.vale.ini${RESET} StylesPath = to the full path of your home directory, relative doesn't work, I couldn't use ~!

Create/update Deno completions
------------------------------
${GREEN}deno completions bash > deno.sh${RESET}
${GREEN}sudo mv deno.sh /etc/profile.d${RESET}

Install the Microsoft vale style guide
--------------------------------------
${GREEN}url -LOf https://github.com/errata-ai/Microsoft/releases/latest/download/Microsoft.zip${RESET}
${GREEN}nzip Microsoft.zip -d ~/styles${RESET}
${GREEN}m Microsoft.zip${RESET}

# Create example dirs and settings files
${GREEN}mkdir -p ~/styles/Vocab/tech-blogging && touch ~/styles/Vocab/tech-blogging/{accept.txt,reject.txt}${RESET}

Please reboot (or things may not work as expected)
===============================================================================
"
