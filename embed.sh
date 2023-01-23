#!/usr/bin/env bash

dependencies=( "ffmpeg" "ffprobe" )

for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

find_dir=$(find -maxdepth 1 -type d | cut -d '/' -f 2 | fzf | sed 's/\ /\\\ /g')
# find_dir="tmp"

find "${find_dir}" -type d | sed "s/^${find_dir}/${find_dir}-cpy/1" | xargs mkdir
# Make dir at new location


# Extract first song cover in each dir, and crop if needed
find "${find_dir}" -mindepth 1 -name "01 *" -o -name "1 *" | while read f; do
    f=$(echo "${f}" | sed "s/^[^\/]*\//${find_dir}\//1")
    curdir=$(dirname "$f")
    if [[ -n $(ffprobe "${f}" 2> >(grep 1280x720)) ]]; then
        ffmpeg -i "$f" -map 0:v -map -0:V -filter "crop=iw-560" "${curdir}/cover.png"
    else
        ffmpeg -i "$f" -map 0:v -map -0:V -c copy "${curdir}/cover.png"
    fi
done

# Strip metadata
# Embed cover in local pwd
find "${find_dir}" -type f -name "*.m4a" -o -name "*.mp3" | while read f; do
    f=$(echo "${f}" | sed "s/^[^\/]*\//${find_dir}\//1")
    cover=$(find $(dirname "${f}") -type f -name "*.jpg" -o -name "*.png")
    new_f=$(echo "${f}" | sed "s/^${find_dir}/${find_dir}-cpy/1")
    echo -e "${f}\n${new_f}\n${cover}\n\n"
    ffmpeg -i "${f}" -i "${cover}" -map 0:a -map 1 \
        -c:a copy -c:v:0 png -disposition:v:0 attached_pic \
        -metadata album="$(basename "$(dirname "${cover}")" | sed 's/-/ /g')" \
        -metadata title="$(basename "${new_f}" | rev | cut -d '.' -f 1 --complement | rev)" \
        -metadata description="" \
        -metadata synopsis="" \
        "${new_f}"
done

# ffmpeg -i in.mp4 -i IMAGE -map 0 -map 1 -c copy -c:v:1 png -disposition:v:1 attached_pic out.mp4


# Copy over image files
find "${find_dir}" -type f -name "*.png" -o -name "*.jpg" | while read f; do
    new_f=$(echo "${f}" | sed "s/^${find_dir}/${find_dir}-cpy/1")
    cp "${f}" "${new_f}"
done

