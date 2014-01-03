#!/bin/sh

base=/workdir/os
perl -w -I$base/smake $base/smake/smake.pl $*
