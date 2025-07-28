# Jellicle songs
My music manager that is a nightmare to manage, but works surprisingly well.

## Usage
Add [n]ew [p]laylist with [m]etadata
```command
./add -npm
```
Embed image, metadata and other to playlist songs
```command
./embed.sh
```
Play music from selected playlist
```command
./play.sh
```
Play music randomly from subdirs matching *.m4a *.mp3 or *.m4a
```command
./play.sh -r
```
## Create playlist
```bash
find . -name "*.m4a" | sort > all.txt
cp all.txt list.txt
# Select files by removing songs you likes from the file
diff all.txt list.txt | grep "^<" | cut -d ' ' -f 2- > playlists/playlist_name.txt
# Clean up
rm all.txt list.txt
```
