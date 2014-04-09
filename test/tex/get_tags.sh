#!/bin/sh

cat $@ | iconv -f koi8-r -t utf-8 | sed 's/\\/\n\\/g' | grep '^\\[a-z]' | sed 's/\\\([a-z]*\).*$/\1/g' | sort | uniq | sed 's/\(.*\)/#define\t\1    "\1\"/g'
