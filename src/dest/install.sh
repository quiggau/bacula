#!/usr/bin/env sh
#
# install script

prog_dir="$(dirname "$(realpath "${0}")")"
name="$(basename "${prog_dir}")"
version="9.2.1"
var_dir="${prog_dir}/var"

mkdir "${var_dir}"
mkdir "${var_dir}/run"
mkdir "${var_dir}/run/subsys"
