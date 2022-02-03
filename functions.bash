# shellcheck shell=bash

# Call with arguments (${1} path,${2} line to add)
add_to_file() {
    touch "$1"
    grep -qxF "$2" "$1" && echo "$2 exists in ${GREEN}$1${RESET}" || echo "$2" >>"$1"
}

# ${1} filename ${2} strip ${3} newname
install() {
    if [ -f "$BIN_INSTALL_DIR"/"$3" ]; then
        echo -e "\e[00;32m$3\e[00m was previously installed, updating file..."
    fi
    tar --no-same-owner -C "$BIN_INSTALL_DIR"/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
    rm "${1}"
}
