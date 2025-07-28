#!/usr/bin/env bash

set -xe

dependencies=( "ffmpeg" "ffprobe" "tofi" )
for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

# Set top level search directory
find_dir=$(find -mindepth 1 -maxdepth 1 -type d | cut -d '/' -f 2 | tofi | sed 's/\ /\\\ /g')

# Make dir at new location
find "${find_dir}" -type d | sed "s/^${find_dir}/${find_dir}-cpy/1" | xargs mkdir -p

# Extract first song cover in each dir, and crop if needed
find "${find_dir}" -mindepth 1 -maxdepth 1 -type d | while read d
do
    # Don't extract cover if already in directory
    if [ -f "${d}/cover.png" ]; then continue; fi
    printf "[INFO] No cover found in %s\nExtracting from audio file\n" "${d}"

    f=$(find "${d}" -mindepth 1 -name "01 *" -o -name "1 *")
    printf "[INFO] Audio file with cover ${f}\n"

    if [[ -n $(ffprobe "${f}" 2> >(grep 1280x720)) ]]; then
        ffmpeg -i "$f" -map 0:v -map -0:V -filter "crop=iw-560" -nostdin "${d}/cover.png"
    else
        ffmpeg -i "$f" -map 0:v -map -0:V -c copy -nostdin "${d}/cover.png"
    fi

done

# Strip metadata
# Embed cover in local pwd

# Loop over directories
find "${find_dir}" -mindepth 1 -maxdepth 1 -type d | while read d
do
    cover="${d}/cover.png"
    if [ ! -f "${cover}" ]; then exit 1; fi

    # Loop over file in directory
    find "$d" -type f -name "*.m4a" -o -name "*.mp3" -o -name "*.mp4" | while read f; do
        new_f=$(echo "${f}" | sed "s/^${find_dir}/${find_dir}-cpy/1")
        ffmpeg -i "${f}" -i "${cover}" -map 0:a -map 1 \
            -c:a copy -c:v:0 png -disposition:v:0 attached_pic \
            -metadata album="$(basename "$(dirname "${cover}")" | sed 's/-/ /g')" \
            -metadata artist="$(basename "$(dirname "${cover}")" | sed 's/-/ /g')" \
            -metadata title="$(basename "${new_f}" | rev | cut -d '.' -f 1 --complement | rev)" \
            -metadata description="" \
            -metadata synopsis="" \
            -nostdin \
            "${new_f}"
    done
done


# Copy over image files
find "${find_dir}" -type f -name "cover.png" | while read f; do
    new_f=$(echo "${f}" | sed "s/^${find_dir}/${find_dir}-cpy/1")
    cp -f "${f}" "${new_f}"
done

# Copy over metedata
find "${find_dir}" -type f -name "metadata.txt" | while read f; do
    new_f=$(echo "${f}" | sed "s/^${find_dir}/${find_dir}-cpy/1")
    cp -f "${f}" "${new_f}"
done

