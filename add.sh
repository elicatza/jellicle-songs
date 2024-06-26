#!/usr/bin/env bash

dependencies=( "yt-dlp" "fzf" )

for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

parent_dir="${HOME}/media/music/"

function usage {
    printf "Usage: ./add.sh [ -h | --help ]\n"
    exit 1
}

PLAYLIST_ITEMS_OPT=false
PLAYLIST_OPT=false
SINGLE_OPT=false

APPEND_OPT=false
NEW_OPT=false

is_new=true
is_single=true


args=""



OPTS=$(getopt -o 'hanpsmI:' --longoptions 'help,append,new,playlist,single,metadata,playlist-items:' -n "add.sh" -- "$@")
VALID_ARGUMENTS="$?"

if [ $VALID_ARGUMENTS -ne 0 ]; then
    usage
    exit 1
fi

eval set -- "${OPTS}"

# Parse getopt flags
while true; do
    case "$1" in
        -h | --help)
            printf "Add new music\n
            -h, --help    \tPrint help and exit
            -p, --playlist\tAdd playlist
            -I, --playlist-items\tAdd playlist
            -s, --single  \tAdd single song
            -a, --append  \tAdd to directory
            -s, --single  \tMake new directory
            -m, --metadata\tDownload with metadata\n"
            exit 1
            ;;
        -p | --playlist)
            PLAYLIST_OPT=true
            ;;
        -I | --playlist-items)
            PLAYLIST_ITEMS_OPT=true
            shift
            args="${args} --playlist-item ${1}"
            ;;
        -s | --single)
            SINGLE_OPT=true
            ;;
        -a | --append)
            APPEND_OPT=true
            ;;
        -n | -new)
            NEW_OPT=true
            ;;
        -m | -metadata)
            args="${args} --add-metadata --embed-thumbnail"
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
    shift
done

# Checks for conflicting flags. If so exit. 
# If none is used, set default flag.
if [ $SINGLE_OPT == true ] && ([ $PLAYLIST_OPT == true ] || [ $PLAYLIST_ITEMS_OPT == true ]); then
    printf "Conflicting flags: cannot use both single and playlist flag!\nExiting...\n"
    exit 0
fi

if [ $NEW_OPT == true ] && [ $APPEND_OPT == true ]; then
    printf "Conflicting flags: cannot use both new and append flag!\nExiting...\n"
    exit 0
fi

if [ $PLAYLIST_OPT == true ] || [ $PLAYLIST_ITEMS_OPT == true ]; then
    is_single=false
fi

if [ $APPEND_OPT == true ]; then
    is_new=false
fi



printf "Enter URL: "
read url
if [ -z $url ]; then
    printf "Missing input\nExiting...\n"
    exit 0;
fi

dest_dir=$(find "${parent_dir}" -maxdepth 1 -type d | rev | cut -d "/" -f 1 | rev | fzf)
if [ -z "$dest_dir" ]; then
    printf "Exiting...\n"
    exit 1
fi
dest_dir=$(echo "$dest_dir" | awk '{printf "%s/", $0}')


if [ $is_new == true ]; then
    # Enter new directory name
    printf "Enter name: "
    read dest_name
    dest_name=$(echo "$dest_name" | sed 's/\ /-/g')
else
    # Choose old directory
    dest_name=$(find "${parent_dir}${dest_dir}" -maxdepth 1 -type d | rev | cut -d "/" -f 1 | rev | fzf)
fi

full_path="${parent_dir}${dest_dir}${dest_name}/"



if [ $is_single == true ]; then
    output_string="${full_path}%(creator)s - %(title)s.%(ext)s"
else
    output_string="${full_path}%(playlist_index)s %(title)s.%(ext)s"
fi



if [ ! -d "${full_path}" ]; then
    printf "Creating directory \`%s\`\n" "${full_path}"
    mkdir -p ${full_path}
fi


echo $output_string
echo $args

yt-dlp -f 'bestaudio[ext=m4a]' $args -o "${output_string}" "${url}"
