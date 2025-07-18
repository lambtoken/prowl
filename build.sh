#!/bin/bash

linux_bin="./love-runtime/love-11.5-x86_64.appImage"

rm -rf ./build
rm -rf ./diet
mkdir ./build

mkdir -p diet
rsync -a --exclude='diet' ./ ./diet/

cd diet || exit

find src -type f -name '*.lua' | while read -r file; do
    tmpfile="${file}.tmp"
    luasrcdiet "$file" -o "$tmpfile" && mv "$tmpfile" "$file"
done

zip -9 -r "../build/prowl.love" . \
  -x "./luasteam.so" \
     "./libsteam_api.so" \
     "./love-runtime/*" \
     "./build/*" \ "./todo*" \
     "./build.sh" \
     "./.git/*" \
     ".gitignore"

cp -r ./luasteam.so ./libsteam_api.so ../build/

cd ..
rm -rf diet/

# win
mkdir ./build/prowl-win
cp ./love-runtime/love-11.5-win64/* ./build/prowl-win/
cat ./build/prowl-win/lovec.exe ./build/prowl.love > ./build/prowl-win/prowl.exe
rm ./build/prowl-win/love.exe
rm ./build/prowl-win/lovec.exe
rm ./build/prowl-win/readme.txt
rm ./build/prowl-win/changes.txt

cd ./build
zip -r ./prowl-win.zip ./prowl-win
cd ..
