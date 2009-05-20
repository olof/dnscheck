#!/bin/sh
#
# $Id$

TIDYRC=util/perltidyrc

find . -name contrib -prune -o \( -name '*.pl' -o -name '*.pm' -o -name '*.t' \) -print |\
xargs perltidy --profile=${TIDYRC} --backup-and-modify-in-place
find . \( -name '*.pl.bak' -o -name '*.pm.bak' -o -name '*.t.bak' \) -type f -print |\
xargs rm
