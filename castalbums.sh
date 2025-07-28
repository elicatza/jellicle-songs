#!/usr/bin/env bash


# Check for required dependencies
dependencies=( "pup" "tofi" "tmux" )
for i in "${dependencies[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        printf "${i} is required!\n";
        exit 1;
    }
done

tld=$(find -maxdepth 1 -type d | cut -d '/' -f 2 | tofi | sed 's/\ /\\\ /g')

# Select musical directory
musical=$(find "${tld}" -maxdepth 1 -type d | rev | cut -d '/' -f 1 | rev | tofi | sed 's/\ /\\\ /g')
if [ -z $musical ]; then
    printf "Invalid selection\n"
    exit 0
fi



# firefox "https://castalbums.org/search/?search=${musical}"
# printf "Enter castalbums link: "
# read url
#
# if [ -z $url ]; then
#     printf "Invalid link\n"
#     printf "Exiting...\n"
#     exit 0
# fi
#
#
# curl -j -c /tmp/cookies.txt -H @headers_castalbums.txt "$url" -o /tmp/castalbums_website.html


rm /tmp/castalbums_verify_data.txt

{
    echo "Opening date: "
    echo "Closing date: "
    echo "Performances: "

    cat /tmp/castalbums_website.html | grep "<b>Music:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Music by:"
    cat /tmp/castalbums_website.html | grep "<b>Lyrics:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Lyrics by:"
    cat /tmp/castalbums_website.html | grep "<b>Book:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Book by:"
    cat /tmp/castalbums_website.html | grep "<b>Director:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Directed by:"
    cat /tmp/castalbums_website.html | grep "<b>Producer:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Produced by:"
    cat /tmp/castalbums_website.html | grep "<b>Orchestrations:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Music orchestrated by:"

    cat /tmp/castalbums_website.html | grep "<b>Performer:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Performed by:"
    cat /tmp/castalbums_website.html | grep "<b>Musician:" -A 1 | pup 'a text{}' | tr '\n' ',' | sed 's/,/, /g'  | sed 's/,.$//' | xargs echo "Played by:"
} >> /tmp/castalbums_verify_data.txt

# Information about off-broadway productions (a new brain)
# https://www.spectra.theater/playhub/pr/e2dac16e-fd69-5525-9aaa-714f76c103fd


tmux new-window -n "verify" "nvim /tmp/castalbums_verify_data.txt;tmux wait-for -S verification-done" \; \
    wait-for verification-done

if [ -s /tmp/castalbums_verify_data.txt ]; then
    filename="./${tld}/${musical}/metadata.txt"
    cp /tmp/castalbums_verify_data.txt $filename
    printf "Writing to %s\n" $filename
fi
