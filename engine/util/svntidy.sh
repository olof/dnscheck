#!/bin/sh
#
# $Id$

TIDYRC=util/perltidyrc

svn status -q | egrep '\.pl$|\.pm$' | awk '{print $2}' |\
xargs perltidy --profile=${TIDYRC} --backup-and-modify-in-place
find . \( -name '*.pl.bak' -o -name '*.pm.bak' \) -type f -print |\
xargs rm
