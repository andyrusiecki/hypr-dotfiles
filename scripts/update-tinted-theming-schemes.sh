#!/bin/bash
# color scheme docs: https://github.com/tinted-theming/home/blob/main/styling.md#specific-colors-and-their-usages

workspace=$(mktemp -d)
schemes_dir="$(realpath $(dirname $0)/../wal/colorschemes)"

git clone https://github.com/tinted-theming/schemes.git $workspace/schemes

for i in $workspace/schemes/base16/*; do
	filename=$(basename "$i")
	name="${filename%.*}"
	ext="${filename##*.}"

	if [ "$ext" = "yaml" ]; then
		variant="$(yq -r '.variant' $i)"
		file="$schemes_dir/$variant/tt-$name.json"

		yq '.palette | {
			special: {
				background: .base00,
				foreground: .base07,
				cursor: .base07
			},
			colors: {
				color0: .base00,
				color1: .base08,
				color2: .base0B,
				color3: .base0A,
				color4: .base0D,
				color5: .base0E,
				color6: .base0C,
				color7: .base05,
				color8: .base03,
				color9: .base08,
				color10: .base0B,
				color11: .base0A,
				color12: .base0D,
				color13: .base0E,
				color14: .base0C,
				color15: .base07
			}
		}' $i > $file
	fi
done

rm -rf $workspace

