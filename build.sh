#!/bin/bash

linux_bin="./love-runtime/love.appImage"

rm -rf ./build
mkdir ./build

zip -9 -r "./build/prowl.love" . -x ./luasteam.so ./libsteam_api.so
cp ./luasteam.so ./libsteam_api.so ./build/
