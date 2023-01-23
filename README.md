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

## TODO
Check if user input is valid.
WARNING: Now it can possibly do weird things with invalid input


There is also something going wrong in embed.sh.
50% of the time it works every time.


Rewrite program in rust
