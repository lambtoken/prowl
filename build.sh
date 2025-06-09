#!/bin/bash

linux_bin="./love-runtime/love-11.5-x86_64.appImage"

rm -rf ./build
mkdir ./build

zip -9 -r "./build/prowl.love" . \
  -x "./luasteam.so" \
     "./libsteam_api.so" \
     "./love-runtime/*" \
     "./build/*" \ "./todo*" \
     "./build.sh" \
     "./.git/*"

cp -r ./luasteam.so ./libsteam_api.so ./build/

# win
mkdir ./build/prowl-win
cp ./love-runtime/love-11.5-win64/* ./build/prowl-win/
cat ./build/prowl-win/love.exe ./build/prowl.love > ./build/prowl-win/prowl.exe
rm ./build/prowl-win/love.exe
rm ./build/prowl-win/lovec.exe
rm ./build/prowl-win/readme.txt
rm ./build/prowl-win/changes.txt

cd ./build
zip -r ./prowl-win.zip ./prowl-win
cd ..
