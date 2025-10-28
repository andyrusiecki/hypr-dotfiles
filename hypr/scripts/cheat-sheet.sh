#!/bin/bash

grep -h '^bind.*' $DOTFILES_DIR/hypr/bindings/* | awk -F',' '{print $1, $2, $3}'
