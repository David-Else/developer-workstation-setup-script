#!/bin/bash
# shellcheck enable=check-unassigned-uppercase

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
#      VERSION: 2.0
#==============================================================================
set -euo pipefail
exec 2> >(tee "error_log_$(date -Iseconds).txt")

if [ "$(id -u)" != 0 ]; then
    echo "You're not root! Run script with sudo" && exit 1
fi

BIN_INSTALL_DIR=/usr/local/bin
WD="$(pwd)"

source /etc/os-release
source functions.bash
source colors.bash
source install-github-binaries.bash

#==============================================================================
# For RHEL and Fedora
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
    nodejs
    optipng
    podman
    podman-docker
    stow
    thunderbird
    transmission-gtk
    xclip)

flathub_packages_to_install=(
    fr.handbrake.ghb
    org.signal.Signal)

npm_global_packages_to_install=(
    vscode-langservers-extracted
    bash-language-server
    live-server
    prettier)

#==============================================================================
# For RHEL Only
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
    git-delta
    zathura
    zathura-bash-completion
    zathura-pdf-mupdf)

display_user_settings_and_prompt() {
    clear
    cat <<EOL
$ID $VERSION_ID detected

${BOLD}Packages to remove${RESET}
${BOLD}------------------${RESET}
RPM: ${GREEN}${rpm_packages_to_remove[*]}${RESET}

${BOLD}Packages to install${RESET}
${BOLD}-------------------${RESET}
RPM: ${GREEN}${rpm_packages_to_install[*]}${RESET}

Flathub: ${GREEN}${flathub_packages_to_install[*]}${RESET}

NPM global packages: ${GREEN}${npm_global_packages_to_install[*]}${RESET}

EOL
    read -rp "Press enter to install, or ctrl+c to quit"
}

#==============================================================================
# For RHEL only
#==============================================================================
if [[ ("$ID" == "centos" || "$ID" == "rocky" || "$ID" == "rhel" || "$ID" == "almalinux") && "${VERSION_ID%.*}" -gt 7 ]]; then

    add_redhat_repositories() {
        dnf module enable -y nodejs:16
        dnf -y config-manager --enable powertools
        dnf -y install epel-release
        dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
        dnf -y config-manager --add-repo https://download.opensuse.org/repositories/home:stig124:nnn/CentOS_8/home:stig124:nnn.repo
    }

    display_user_settings_and_prompt
    add_redhat_repositories
    rpm_packages_to_remove+=("${rhel_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${rhel_rpm_packages_to_install[@]}")
    flathub_packages_to_install+=("${rhel_flathub_packages_to_install[@]}")

    #==========================================================================
    # For Fedora only
    #==========================================================================
elif [ "$ID" == "fedora" ]; then

    add_fedora_repositories() {
        dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        dnf -y config-manager --add-repo https://download.opensuse.org/repositories/home:stig124:nnn/Fedora_34/home:stig124:nnn.repo
    }

    display_user_settings_and_prompt
    add_fedora_repositories
    rpm_packages_to_remove+=("${fedora_rpm_packages_to_remove[@]}")
    rpm_packages_to_install+=("${fedora_rpm_packages_to_install[@]}")

#==============================================================================
# For Unsupported OS / RHEL or clone version <8
#==============================================================================
else
    echo "Unsupported OS or version" && exit 1
fi

#==============================================================================
# Add more repositories depending if packages are chosen for RHEL and Fedora
#==============================================================================
add_repositories() {
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
    echo "${BOLD}Removing unwanted programs...${RESET}"
    dnf -y remove "${rpm_packages_to_remove[@]}"

    echo "${BOLD}Updating...${RESET}"
    dnf -y --refresh upgrade

    echo "${BOLD}Installing packages...${RESET}"
    dnf -y install "${rpm_packages_to_install[@]}"

    echo "${BOLD}Installing flathub packages...${RESET}"
    flatpak install -y flathub "${flathub_packages_to_install[@]}"

    echo "${BOLD}Installing github binaries...${RESET}"
    install_github_binaries

    echo "${BOLD}Installing Deno...${RESET}"
    su - "$SUDO_USER" -c "curl -fsSL https://deno.land/x/install/install.sh | sh"

    echo "${BOLD}Installing Kitty...${RESET}"
    su - "$SUDO_USER" -c "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"

    # Install neoplug
    su - "$SUDO_USER" -c "curl -fLo /home/$SUDO_USER/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

    echo "${BOLD}Installing nnn terminal file manager plugins...${RESET}"
    su - "$SUDO_USER" -c "curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh"

    if command -v mpv &>/dev/null; then
        echo "${BOLD}Installing umpv script for additional MPV functionality...${RESET}"
        curl https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/umpv -o "$BIN_INSTALL_DIR/umpv"
        chmod +x "$BIN_INSTALL_DIR/umpv"
    fi

    if command -v node &>/dev/null; then
        echo "${BOLD}Installing NPM global packages..."
        npm install -g "${npm_global_packages_to_install[@]}"
    fi

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
    add_to_file "/etc/sysctl.d/90-sysrq.conf" "kernel.sysrq = 1"
}

display_end_message() {
    cat <<EOL

${BOLD}Congratulations, everything is installed!${RESET}

For RHEL clones: ${GREEN}sudo dnf install extras/abattis-cantarell-fonts-0.111-2.fc30.noarch.rpm${RESET} to upgrade 0.0.25

To install Visual Studio Code icons for the Neovim completion plugin double click the extras/codicon.ttf file in Gnome Files

To install Python applications: ${GREEN}pip3 install --user yt-dlp gitlint trash-cli tldr${RESET}
 
Now use the setup script...

EOL
}

add_repositories
install_all
display_end_message
