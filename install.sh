#!/bin/bash

#==============================================================================
# Developer Workstation Setup Script
#
# DESCRIPTION: Post-install script for Fedora and RHEL 8 clones to create your
#              ultimate development environment
#
#      WEBSITE: https://github.com/David-Else/developer-workstation-setup-script
#
# REQUIREMENTS: Freshly installed Fedora 34+, or RHEL 8 clone installed with
#               software selection = workstation
#
#       AUTHOR: David Else
#      COMPANY: https://www.elsewebdevelopment.com/
#      VERSION: 2.3
#==============================================================================
set -euo pipefail
exec 2> >(tee "error_log_$(date -Iseconds).txt")

source functions.bash
source colors.bash
source /etc/os-release

confirm_user_is 'root'

#==============================================================================
# Packages to be installed, modified depending on OS
#==============================================================================
rpm_packages_to_remove=(
    cheese
    gedit
    rhythmbox
    totem)

rpm_packages_to_install=(
    ImageMagick
    borgbackup
    # code
    ffmpeg
    fuse-exfat
    gcc-c++
    gh
    gnome-tweaks
    keepassxc
    lazygit
    # libva-intel-driver
    # mesa-vdpau-drivers
    mediainfo
    mpv
    nnn
    neovim
    nodejs
    optipng
    podman
    stow
    thunderbird
    transmission-gtk
    xclip)

flathub_packages_to_install=(
    fr.handbrake.ghb
    org.signal.Signal)

npm_global_packages_to_install=(
    prettier)

#==============================================================================
# For RHEL or clones Only
#==============================================================================
rhel_rpm_packages_to_remove=(
    evolution
    firefox)

rhel_rpm_packages_to_install=(
    java-11-openjdk-headless
    python36-devel)

rhel_flathub_packages_to_install=(
    org.mozilla.firefox
    org.kde.krita
    org.gnome.Shotwell
    # org.winehq.Wine
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
    shotwell
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
        dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
        dnf -y config-manager --add-repo https://download.opensuse.org/repositories/home:stig124:nnn/CentOS_8/home:stig124:nnn.repo
    }

    rpm_packages_to_remove+=("${rhel_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${rhel_rpm_packages_to_install[@]}")
    flathub_packages_to_install+=("${rhel_flathub_packages_to_install[@]}")
    display_user_settings_and_prompt
    add_redhat_repositories

    #==========================================================================
    # For Fedora only
    #==========================================================================
elif [ "$OS" == "valid_fedora" ]; then

    add_fedora_repositories() {
        dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        dnf -y config-manager --add-repo https://download.opensuse.org/repositories/home:stig124:nnn/Fedora_35/home:stig124:nnn.repo
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
# Add more repositories, some depending if packages have been selected
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

display_text "

${BOLD}Congratulations, everything is installed!${RESET}

For RHEL clones: ${GREEN}sudo dnf install extras/abattis-cantarell-fonts-0.111-2.fc30.noarch.rpm${RESET} to upgrade 0.0.25

To install Visual Studio Code icons for the Neovim completion plugin double click the ${GREEN}extras/codicon.ttf${RESET} file in Gnome Files

RHEL: To install Python applications: ${GREEN}pip3 install --user yt-dlp gitlint trash-cli tldr${RESET}
Fedora: To install Python applications: ${GREEN}pip3 install --user gitlint trash-cli tldr${RESET}
 
Now install the binaries with ${GREEN}./install-binaries.bash${RESET}...
"
