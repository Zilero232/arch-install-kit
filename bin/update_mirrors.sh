#!/bin/bash

echo "Updating mirror list..."

# Create backup of current mirror list.
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Update mirror list.
sudo reflector --protocol https \
    --country Russia,Belarus,Kazakhstan \
    --age 6 \
    --ipv4 \
    --fastest 10 \
    --download-timeout 10 \
    --sort score \
    --save /etc/pacman.d/mirrorlist

if [ $? -eq 0 ]; then
    echo "Mirror list has been successfully updated!"
    echo "Backup saved to /etc/pacman.d/mirrorlist.backup"
else
    echo "Error updating mirror list."
    echo "Restoring previous mirror list..."

    sudo mv /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist
fi