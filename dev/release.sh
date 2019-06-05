#!/usr/bin/env bash

echo -e "\nBuild Release"
echo "--------------"
read -p "Version: " VER
if [ -z $VER ]; then
    echo "No version given. Exiting."
    exit 1
fi
read -p "Platform (W32, W64, M or D for Win32, Win64, macOS or Debian): " PLAT
if [ -z $PLAT ]; then
    echo "No platform given. Exiting."
    exit 1
fi

# The love version to build against
LOVER="11.2"

# Build!
love-release -$PLAT -t "nova-pinball-$VER" --uti "com.github.nova-pinball" -l $LOVER -v $VER -x image-sources\/\* -x dev\/\* -x nova-pinball-engine\/editor\/\*