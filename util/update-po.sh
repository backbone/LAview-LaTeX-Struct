#!/bin/sh

##
# settings
##
PROJECT=laview-latex-struct-0
PO_DIR_NAME=po

SCRIPT_PATH=`readlink -f $0`
SCRIPT_DIR=${SCRIPT_PATH%/*}
PRJDIR=${SCRIPT_DIR%/*}

C_FILELIST="${PRJDIR}/src/*.vala"
UI_FILELIST="${PRJDIR}/ui/*.glade"

##
# code
##
xgettext --language=C --escape --package-name=$PROJECT --default-domain=$PROJECT --add-comments=/// \
  -k_ -kQ_ -kC_ -kN_ -kNC_ -kg_dgettext -kg_dcgettext \
  -kg_dngettext -kg_dpgettext -kg_dpgettext2 -kg_strip_context -F -n -o \
  $PRJDIR/$PO_DIR_NAME/source.pot $C_FILELIST

xgettext --language=C --escape --package-name=$PROJECT --default-domain=$PROJECT --add-comments=/// \
  -k_ -kQ_ -kC_ -kN_ -kNC_ -kg_dgettext -kg_dcgettext \
  -kg_dngettext -kg_dpgettext -kg_dpgettext2 -kg_strip_context -F -n -o \
  $PRJDIR/$PO_DIR_NAME/glade.pot $C_FILELIST

msgcat -o $PRJDIR/$PO_DIR_NAME/$PROJECT.pot --use-first $PRJDIR/$PO_DIR_NAME/source.pot $PRJDIR/$PO_DIR_NAME/glade.pot

rm $PRJDIR/$PO_DIR_NAME/source.pot
rm $PRJDIR/$PO_DIR_NAME/glade.pot

[ 0 != $? ] && echo "xgettext failed ;-(" && exit 1
[ ! -e $PRJDIR/$PO_DIR_NAME/$PROJECT.pot ] && echo "No strings found ;-(" && exit 1

for d in $PRJDIR/$PO_DIR_NAME/*; do
  [ ! -d $d ] && continue

  if [ -e $d/$PROJECT.po ]; then
    echo "Merging '${d##*/}' locale" && msgmerge -F -U $d/$PROJECT.po $PRJDIR/$PO_DIR_NAME/$PROJECT.pot
    [ 0 != $? ] && echo "msgmerge failed ;(" && exit 1
  else
    echo "Creating '${d##*/}' locale" && msginit -l ${d##*/} -o  $d/$PROJECT.po -i $PRJDIR/$PO_DIR_NAME/$PROJECT.pot
    [ 0 != $? ] && echo "msginit failed ;(" && exit 1
  fi

done
