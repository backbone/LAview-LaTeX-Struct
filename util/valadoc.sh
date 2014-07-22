#!/bin/bash

EXE_PATH="`readlink -f $0`"
PRJ_PATH="${EXE_PATH%/*/*}"
OUT_PATH="$PRJ_PATH/doc/html/latex-struct"
OUT_INTERNAL_PATH="$PRJ_PATH/doc/html/latex-struct-internals"

echo "Generating documentation..."
rm -rf "$OUT_PATH"
valadoc --no-protected -o "$OUT_PATH" -b "$PRJ_PATH/src" `find "$PRJ_PATH/src" -name "*.vapi" -or -name "*.vala"` \
  --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=gmodule-2.0 --pkg=posix
firefox "$OUT_PATH"/latex-struct/index.htm &>/dev/null

#echo "Generating internal documentation..."
#rm -rf "$OUT_INTERNAL_PATH"
#valadoc -o "$OUT_INTERNAL_PATH" -b "$PRJ_PATH/src" `find "$PRJ_PATH/src" -name "*.vapi" -or -name "*.vala"` \
#  --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=gmodule-2.0 --pkg=posix --internal

#firefox "$OUT_INTERNAL_PATH"/latex-struct-internals/index.htm &>/dev/null
