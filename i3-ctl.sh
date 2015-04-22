#!/bin/bash
# This script wrap Ruby executable.

rvm default do ruby $HOME/.i3/i3-ctl.rb "$@"
