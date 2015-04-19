#!/bin/bash
# Rename current workspace

# deafult name and imput
name=$(echo -e "massterm" | dmenu)

rvm default do ruby $HOME/.i3/i3-ctl.rb "$name"
