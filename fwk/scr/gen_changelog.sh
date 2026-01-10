#!/usr/bin/env bash

# generate changelog based on auto-changelog
#
# Install changelog tool
#> pip install auto-changelog
#
# example usage:
# ./scr/gen_changelog.sh mirror "FPGA Firmware Framework (FWK) changelog generated based on conventional commit messages."

REMOTE=${1:-origin}
DESCRIPTION=${2:-"Changelog generated based on conventional commit messages."}

auto-changelog --gitlab \
               -u \
               -r $REMOTE \
               -o doc/modules/ROOT/pages/CHANGELOG.adoc \
               --template tpl/changelog/default.adoc.jinja2 \
               -d "$DESCRIPTION"

