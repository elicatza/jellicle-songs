#!/usr/bin/env bash

dependencies=( "mpv" )

for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

# play=$(ls -d -1 */ | fzf)
dir=$(pwd)

function usage {
    printf "Usage: ./play.sh [ -h | --help ]\n"
    exit 1
}

op_random=false
op_playlist=false
PLAYLISTDIR="./playlists"

OPTS=$(getopt -o 'prh' --longoptions 'playlist,random,help' -n "play.sh" -- "$@")

VALID_ARGUMENTS="$?"

if [ $VALID_ARGUMENTS -ne 0 ]; then
    usage
fi

eval set -- "${OPTS}"

while true; do
    case "$1" in
        -h | --help)
            printf "Play music\n
            -h, --help  \tPrint help and exit
            -w, --random\tPlay random music\n"
            exit 1
            ;;
        -r | random)
            op_random=true
            shift
            continue
            ;;
        -p | playlist)
            op_playlist=true
            shift
            continue
            ;;
        --)
            shift
            break
            ;;
        *)
            printf "Internal error" >&2
            exit 1
            ;;
    esac
done

if [ $op_random = true ]; then
    find -mindepth 2 -type f -name "*.m4a" -o -name "*.mp3" -o -name "*.weba" | \
        sort -R | \
        awk '{printf "\"%s\" ", $0}' | \
        xargs mpv --no-video
elif [ $op_playlist = true ]; then
    playlist=$(find "${PLAYLISTDIR}" -maxdepth 1 -type f | rev | cut -d "/" -f 1 | rev | fzf)
    mpv --playlist="${PLAYLISTDIR}/${playlist}" --shuffle --no-video
else
    category=$(find -maxdepth 1 -type d | cut -d '/' -f 2 | fzf | sed 's/\ /\\\ /g')

    list=$(find "$category" -maxdepth 1 -type d | cut -d '/' -f 2 | fzf | sed 's/\ /\\\ /g')

    # mpv $(echo "${dir}/${category}/${list}/*") --no-video --audio-device=alsa/bluealsa
    mpv $(echo "${dir}/${category}/${list}/*.m4a") --no-video
fi
