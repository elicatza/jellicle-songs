#!/usr/bin/env bash


# Check for required dependencies
dependencies=( "pup" "tofi" "tmux" )
for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

musical=$(find "musicals" -maxdepth 1 -type d | rev | cut -d '/' -f 1 | rev | tofi | sed 's/\ /\\\ /g')
if [ -z $musical ]; then
    printf "Invalid selection\n"
    exit 0
fi

firefox "https://duckduckgo.com/?t=ffsb&q=${musical}+site%3Awww.allmusicals.com"
printf "Enter $musical link: " $musical
read allmusicals

if [ -z $allmusicals ]; then
    printf "Invalid link\n"
    printf "Exiting...\n"
    exit 0
fi


# curl -k "${allmusicals}" -o /tmp/allmusicals.html
lyric_dir="musicals/${musical}/lyrics/"
mkdir -p lyric_dir
tld="https://www.allmusicals.com"
urls=$(pup -f /tmp/allmusicals.html 'ol:parent-of(li.act) a attr{href}' | head -n 2)


echo $urls | while read url; do
    echo "parsing $url"
    title=$(basename $url | sed 's/\.htm/.txt/g' | xargs printf "${lyric_dir}%s")
    printf "[LOG]: File to be written to\n" $title
    curl "${tld}${url}" -k -o /tmp/allmusicals-lyric.html
    printf "[LOG]: Downloading lyric for $url\n"
    pup -f /tmp/allmusicals-lyric.html | pup 'div#page text{}' | tr '\n' '@' | sed 's/@@/\n/g' | sed 's/@//g' | sed "s/&#39;/'/g" | sed 's/&#34;/"/g' > $title
    printf "[LOG]: Writing lyrics to $title\n"
    sleep 2
done


# parse lyrics
