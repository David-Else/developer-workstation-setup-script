#!/bin/bash

#==============================================================================
# Developer Workstation Setup Script
#
# DESCRIPTION: Post-install script for Fedora and RHEL 9 clones to create your
#              ultimate development environment
#
#      WEBSITE: https://github.com/David-Else/developer-workstation-setup-script
#
# REQUIREMENTS: Freshly installed Fedora 34+, or RHEL 9 clone installed with
#               software selection = workstation
#
#       AUTHOR: David Else
#      COMPANY: https://www.elsewebdevelopment.com/
#      VERSION: 3.0
#==============================================================================
set -euo pipefail
exec 2> >(tee "error_log_$(date -Iseconds).txt")

source functions.bash
source colors.bash
source /etc/os-release

confirm_user_is 'root'

#==============================================================================
# Packages to be installed on all OS
#==============================================================================
rpm_packages_to_remove=(
    cheese
    gedit
    rhythmbox
    totem)

rpm_packages_to_install=(
    # code
    # libva-intel-driver
    ImageMagick
    borgbackup
    ffmpeg
    gcc-c++
    gh
    gnome-tweaks
    # keepassxc
    lazygit
    mediainfo
    # mpv
    # nnn
    # kitty
    neovim
    nodejs
    optipng
    # stow
    thunderbird
    # transmission-gtk
    xclip)

flathub_packages_to_install=(
    fr.handbrake.ghb
    org.signal.Signal)

npm_global_packages_to_install=(
    prettier@2.7.1
    vscode-langservers-extracted@4.2.1
    bash-language-server@3.0.5
    typescript-language-server@0.11.2
    typescript@4.7.4)

#==============================================================================
# For RHEL or clones Only
#==============================================================================
rhel_rpm_packages_to_remove=(
    evolution)

rhel_rpm_packages_to_install=(
    git
    java-11-openjdk-headless
    python3-devel)

rhel_flathub_packages_to_install=(
    # org.winehq.Wine
    com.github.tchx84.Flatseal
    com.obsproject.Studio
    org.kde.krita
    org.bunkus.mkvtoolnix-gui)

#==============================================================================
# For Fedora Only
#==============================================================================
fedora_rpm_packages_to_remove=(
    gnome-photos)

fedora_rpm_packages_to_install=(
    krita
    lshw
    mkvtoolnix-gui
    xrandr
    zathura
    zathura-bash-completion
    zathura-pdf-mupdf)

fedora_flathub_packages_to_install=()

#==============================================================================
# Display user settings
#==============================================================================

display_user_settings_and_prompt() {
    clear
    display_text "
$ID $VERSION_ID detected

${BOLD}Packages to remove${RESET}
${BOLD}------------------${RESET}
RPM: ${GREEN}${rpm_packages_to_remove[*]}${RESET}

${BOLD}Packages to install${RESET}
${BOLD}-------------------${RESET}
RPM: ${GREEN}${rpm_packages_to_install[*]}${RESET}

Flathub: ${GREEN}${flathub_packages_to_install[*]}${RESET}

NPM global packages: ${GREEN}${npm_global_packages_to_install[*]}${RESET}
"
    echo
    read -rp "Press enter to install, or ctrl+c to quit"
}

detect_os

#==============================================================================
# For RHEL or clones only
#==============================================================================
if [[ "$OS" == "valid_rhel" ]]; then

    add_redhat_repositories() {
        dnf -y config-manager --enable crb
        dnf -y install epel-release
        dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
    }

    rpm_packages_to_remove+=("${rhel_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${rhel_rpm_packages_to_install[@]}")
    flathub_packages_to_install+=("${rhel_flathub_packages_to_install[@]}")
    display_user_settings_and_prompt
    add_redhat_repositories

    dnf -y install ./el9-rebuilds/stow-2.3.1-1.el9.noarch.rpm ./el9-rebuilds/stow-doc-2.3.1-1.el9.noarch.rpm ./el9-rebuilds/aiksaurus-1.2.1-48.el9.x86_64.rpm
    #==========================================================================
    # For Fedora only
    #==========================================================================
elif [ "$OS" == "valid_fedora" ]; then

    add_fedora_repositories() {
        dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    }

    rpm_packages_to_remove+=("${fedora_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${fedora_rpm_packages_to_install[@]}")
    flathub_packages_to_install+=("${fedora_flathub_packages_to_install[@]}")
    display_user_settings_and_prompt
    add_fedora_repositories

#==============================================================================
# Exit if unsupported OS
#==============================================================================
else
    echo "Unsupported OS or version" && exit 1
fi

#==============================================================================
# Add more repositories depending on packages installed
#==============================================================================
add_conditional_repositories() {
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # spaces around strings ensure something like 'notnode' could not trigger 'nodejs' using [*]
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
}

#==============================================================================
# Remove unwanted programs, update system and install everything
#==============================================================================
install_all() {
    echo -e "${BOLD}Removing unwanted programs...${RESET}"
    dnf -y remove "${rpm_packages_to_remove[@]}"

    echo -e "${BOLD}Updating...${RESET}"
    dnf -y --refresh upgrade

    echo -e "${BOLD}Installing packages...${RESET}"
    dnf -y install "${rpm_packages_to_install[@]}"

    echo -e "${BOLD}Installing flathub packages...${RESET}"
    flatpak install -y flathub "${flathub_packages_to_install[@]}"

    if command -v node &>/dev/null; then
        echo -e "${BOLD}Installing NPM global packages..."
        npm install -g "${npm_global_packages_to_install[@]}"
    fi
}

add_conditional_repositories
install_all

# TEMP DELETE!!
dnf install kitty nnn --enablerepo=epel-testing

# neovim will fail 2nd time as dir exists
case " ${rpm_packages_to_install[*]} " in
*' nnn '*)
    su - "$SUDO_USER" -c "curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh"
    ;;&
*' neovim '*)
    su - "$SUDO_USER" -c "git clone --depth=1 https://github.com/savq/paq-nvim.git ~/.local/share}/nvim/site/pack/paqs/start/paq-nvim"
    ;;
esac

display_text "

${BOLD}Congratulations, everything is installed!${RESET}

To install Visual Studio Code icons for the Neovim completion plugin double click the ${GREEN}extras/codicon.ttf${RESET} file in Gnome Files

RHEL:   To install Python applications: ${GREEN}pip3 install --user yt-dlp gitlint trash-cli tldr${RESET}
Fedora: To install Python applications: ${GREEN}pip3 install --user gitlint trash-cli tldr${RESET}
 
Now install the binaries with ${GREEN}./install-binaries.bash${RESET}...
"
