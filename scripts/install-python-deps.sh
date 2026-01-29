#!/bin/bash

venv_dir="$(realpath $(dirname $0)/../python)"

python3.13 -m venv "$venv_dir"
. $venv_dir/bin/activate

pip3 install pywal16
pip3 install pywalfox

pywalfox install
