# shellcheck shell=bash

# Call with arguments (${1} path,${2} line to add)
add_to_file() {
    touch "$1"
    grep -qxF "$2" "$1" && echo "$2 exists in ${GREEN}$1${RESET}" || echo "$2" >>"$1"
}

# Call with arguments (${1} location,${2} filename,${3} sha)
download_verify() {
    curl -LOf "https://github.com/${1}${2}"
    echo "${3} ./${2}" | sha512sum --check
}

# Call with arguments (${1} filename,${2} strip,${3} newname)
install() {
    tar --no-same-owner -C $BIN_INSTALL_DIR/ -xf "${1}" --no-anchored "${3}" --strip="${2}"
    rm "${1}"
}
