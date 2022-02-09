# shellcheck shell=bash

# Adds a line of code to a file if it is not there already
# ${1} file path ${2} line of code to add to file
add_to_file() {
    touch "$1"
    grep -qxF "$2" "$1" && echo "$2 exists in ${GREEN}$1${RESET}" || echo "$2" >>"$1"
}

# Extracts a file from a tar archieve into a directory
# ${1} filename ${2} strip ${3} newname
install() {
    if [ -f "$BIN_INSTALL_DIR"/"$3" ]; then
        echo -e "${GREEN}$3${RESET} was previously installed"
        read -p "Would you like to keep the existing version? " -n 1 -r && echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return
        fi

    fi
    tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
}

# Confirm the user is either normal or root and exit if they are not
# ${1} normal|root
confirm_user_is() {
    USER_STATUS=$(id -u)
    echo $USER_STATUS
    if [[ "$USER_STATUS" != 0 && ${1} == "root" ]]; then
        echo "You're not root! Run script with sudo" && exit 1
    elif [[ "$USER_STATUS" == 0 && ${1} == "normal" ]]; then
        echo "You're root! Run script as user" && exit 1
    fi
}

# Detects OS, and if valid sets a global variable OS to valid_rhel/valid_fedora
detect_os() {
    if [[ ("$ID" == "centos" || "$ID" == "rocky" || "$ID" == "rhel" || "$ID" == "almalinux") && "${VERSION_ID%.*}" -gt 7 ]]; then
        OS='valid_rhel'
    elif [[ "$ID" == "fedora" && "${VERSION_ID%.*}" -gt 33 ]]; then
        OS='valid_fedora'
    fi
}

# Display a block of text with color ANSI escape codes
display_text() {
    echo -e "$(
        cat <<EOL
        ${1}
EOL
    )"
}
