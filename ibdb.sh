#!/usr/bin/env bash

# TODO Things are comming up twice
# Se: pup -i 0 -f /tmp/ibdb_website.html 'div#Replacements a[href^="/broadway-cast-staff/"]'

# Check for required dependencies
dependencies=( "pup" "tofi" "tmux" )
for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

tld=$(find -maxdepth 1 -type d | cut -d '/' -f 2 | tofi | sed 's/\ /\\\ /g')

musical=$(find "${tld}" -maxdepth 1 -type d | rev | cut -d '/' -f 1 | rev | tofi | sed 's/\ /\\\ /g')
if [ -z $musical ]; then
    printf "Invalid selection\n"
    exit 0
fi

firefox "https://duckduckgo.com/?t=ffsb&q=${musical}+site%3Aibdb.com"
printf "Enter ibdb link: "
read ibdb

if [ -z $ibdb ]; then
    printf "Invalid link\n"
    printf "Exiting...\n"
    exit 0
fi


# url="https://www.ibdb.com/broadway-production/can-can-2234#ProductionStaff"
curl -j -c /tmp/cookies.txt -H @headers.txt "$ibdb" -o /tmp/ibdb_website.html


rm /tmp/ibdb_verify_data.txt
{
    pup -f /tmp/ibdb_website.html ':parent-of(div.xt-lable:contains("Opening Date")) div.xt-main-title text{}' | xargs echo "Opening date:"
    pup -f /tmp/ibdb_website.html ':parent-of(div.xt-lable:contains("Closing Date")) div.xt-main-title text{}' | xargs echo "Closing date:"
    pup -f /tmp/ibdb_website.html ':parent-of(div.xt-lable:contains("Performances")) div.xt-main-title text{}' | xargs echo "Performances:"
} >> /tmp/ibdb_verify_data.txt

# No semicolon after `Produced by`.
categories=("Music by" "Lyrics by" "Book by" "Directed by" "Produced by" "Music orchestrated by")
for i in "${categories[@]}"; do
    pup -i 0 -f /tmp/ibdb_website.html 'div#ProductionStaff' \
        | sed -n "/${i}/,/;/p" | pup 'a text{}' \
        | sed '/^[[:blank:]]*$/d' | sort | uniq \
        | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g' | sed 's/&amp;/\&/g' \
        | xargs echo "${i}:" >> /tmp/ibdb_verify_data.txt
done

{
    pup -i 0 -f /tmp/ibdb_website.html 'div#ProductionStaff a[href^="/broadway-cast-staff/"] text{}' \
        | sed 's/,//g' | sort | uniq \
        | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g' \
        | xargs echo "Production staff:"
    pup -i 0 -f /tmp/ibdb_website.html 'div#OpeningNightCast a[href^="/broadway-cast-staff/"] text{}' \
        | sed 's/,//g' | cat -n | sort -uk2 | sort -n | cut -f 2- \
        | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g' \
        | xargs echo -e "Opening night cast:"
    pup -i 0 -f /tmp/ibdb_website.html 'div#Replacements a[href^="/broadway-cast-staff/"] text{}' \
        | sed 's/,//g' | cat -n | sort -uk2 | sort -n | cut -f 2- \
        | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g' \
        | xargs echo -e "Replacements:"
} >> /tmp/ibdb_verify_data.txt

tmux new-window -n "verify" "nvim /tmp/ibdb_verify_data.txt;tmux wait-for -S verification-done" \; \
    wait-for verification-done

if [ -s /tmp/ibdb_verify_data.txt ]; then
    filename="./${tld}/${musical}/metadata.txt"
    cp /tmp/ibdb_verify_data.txt $filename
    printf "Writing to %s\n" $filename
fi

