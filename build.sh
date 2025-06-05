#!/bin/bash

linux_bin="./love-runtime/love-11.5-x86_64.appImage"

rm -rf ./build
mkdir ./build

zip -9 -r "./build/prowl.love" . -x ./luasteam.so ./libsteam_api.so
cp -r ./luasteam.so ./libsteam_api.so ./build/

# win
mkdir ./build/love-win
cp ./love-runtime/love-11.5-win64/* ./build/love-win/
cat ./build/love-win/love.exe ./build/prowl.love > ./build/love-win/prowl.exe
rm ./build/love-win/love.exe
rm ./build/love-win/lovec.exe
rm ./build/love-win/readme.txt
rm ./build/love-win/changes.txt

zip -r ./build/love-win.zip ./build/love-win
