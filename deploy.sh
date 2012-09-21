#!/bin/bash

# Usage: ./deploy.sh [host]

if test -n "$1"; then
	HOST="$1"
else
	echo "You must supply a deployment host."
  exit 1
fi

tar cj . | ssh -o 'StrictHostKeyChecking no' "$HOST" '
sudo rm -rf ~/chef &&
mkdir ~/chef &&
cd ~/chef &&
tar xj &&
sudo bash install.sh'
