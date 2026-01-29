#!/bin/bash
# themes: https://github.com/basecamp/omarchy/tree/master/themes

workspace=$(mktemp -d)
schemes_dir="$(realpath $(dirname $0)/../themes)"

git clone https://github.com/basecamp/omarchy.git $workspace/omarchy
cp -r $workspace/omarchy/themes/* $schemes_dir/

rm -rf $workspace
