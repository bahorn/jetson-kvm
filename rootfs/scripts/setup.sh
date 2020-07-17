#!/bin/bash
# bootstrap script for our system.
# This runs inside the chroot.
pacman-key --init
pacman-key --populate


pacman -Syu --noconfirm
cat /packages.txt | xargs pacman --noconfirm -S


rm /packages.txt
rm /setup.sh
