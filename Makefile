# $Id$

TIDYRC=util/perltidyrc


all:

tidy:
	find . \( -name '*.pl' -o -name '*.pm' \) -type f -print |\
	xargs perltidy --profile=${TIDYRC} --backup-and-modify-in-place
	find . \( -name '*.pl.bak' -o -name '*.pm.bak' \) -type f -print |\
	xargs rm
