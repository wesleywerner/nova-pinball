#!/usr/bin/env bash

echo -e "\nBuild Release"
echo "--------------"
read -p "Version: " VER
if [ -z $VER ]; then
    echo "No version given. Exiting."
    exit 1
fi

# The love version to build against
LOVER="0.9.2"

# Win32
love-release -W32 -t "nova-pinball-$VER" -l $LOVER -v $VER -x image-sources\/\* -x dev\/\* -x nova-pinball-engine\/editor\/\*
