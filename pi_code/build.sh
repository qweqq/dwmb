path="$(dirname "$(readlink -f "${0}")")"

packages=(dwmb)

build_dir="${path}/cross_bin"
sounds_dir="${path}/sounds"
destination="tardis:/home/human/bin"

export GOPATH="${path}"
export GOOS=linux
export GOARCH=arm

function build {
    mkdir -p "${build_dir}"
    for package in ${packages[@]}; do
        cd "${build_dir}"

        go build "${package}"
        
        status=$?
        if [[ "${status}" -ne 0 ]]; then
            return "${status}";
        fi
    done
}

function sync {
    rsync --progress -hvr "${build_dir}/" "${destination}"
}

function copy_sounds {
    rsync --progress -hvr "${sounds_dir}/" "${destination}/sounds"
}

function clean {
    rm -rf "${build_dir}"
}

if [[ "${1}" == "go" ]]; then
    go "${@:2}"
elif [[ "${1}" == "build" ]]; then
    build
elif [[ "${1}" == "sync" ]]; then
    build && sync
elif [[ "${1}" == "copy_sounds" ]]; then
    copy_sounds
elif [[ "${1}" == "clean" ]]; then
    clean
fi
