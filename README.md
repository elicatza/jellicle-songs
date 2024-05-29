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

## Create playlist
```bash
find . -name "*.m4a" | sort > all.txt
cp all.txt list.txt
# Select files by removing songs you likes from the file
diff all.txt list.txt | grep "^<" | cut -d ' ' -f 2- > playlists/quiet.txt
# Clean up
rm all.txt list.txt
```

## Change album cover
* [West side story](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fis5-ssl.mzstatic.com%2Fimage%2Fthumb%2FMusic111%2Fv4%2Fcd%2Ff5%2F58%2Fcdf558cb-4334-9bdd-36c0-8c872792ff64%2F074646072424.jpg%2F1200x1200bf-60.jpg&f=1&nofb=1&ipt=5db5ea506fa6f6824b4879b9a5a61e8a64420b1fdfadfdadd2411bf827701349&ipo=images)
 [Oklahoma!](https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fprodimage.images-bn.com%2Fpimages%2F0601215798128_p0_v1_s600x595.jpg&f=1&nofb=1&ipt=458e156c8f9dd412945a19e9a7f3125239ed11e6f3eda12c1b9703cb9f3a170b&ipo=images)
* [Little shop of horrors](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.Xr8lBtgaUn6RJVk-Dlg61wHaHa%26pid%3DApi&f=1&ipt=c8019c5cec48de264bfeb76b0a46fbcf0650cec27e977eb3f86e5cd3f9b07777&ipo=images)
