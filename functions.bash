# shellcheck shell=bash

# Adds a line of code to a file if it is not there already
# ${1} file path ${2} line of code to add to file
add_to_file() {
    touch "$1"
    grep -qxF "$2" "$1" && echo "$2 exists in ${GREEN}$1${RESET}" || echo "$2" >>"$1"
}

# Confirm the user is either normal or root and exit if they are not
# ${1} normal|root
confirm_user_is() {
    USER_STATUS=$(id -u)
    if [[ "$USER_STATUS" != 0 && ${1} == "root" ]]; then
        echo "You're not root! Run script with sudo" && exit 1
    elif [[ "$USER_STATUS" == 0 && ${1} == "normal" ]]; then
        echo "You're root! Run script as user" && exit 1
    fi
}

# Detects OS, and if valid sets a global variable OS to valid_rhel/valid_fedora
detect_os() {
    if [[ ("$ID" == "eurolinux" || "$ID" == "centos" || "$ID" == "rocky" || "$ID" == "rhel" || "$ID" == "almalinux") && "${VERSION_ID%.*}" -gt 8 ]]; then
        OS='valid_rhel'
    elif [[ "$ID" == "fedora" && "${VERSION_ID%.*}" -gt 35 ]]; then
        OS='valid_fedora'
    else
        OS='invalid'
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
