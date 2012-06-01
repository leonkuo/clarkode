#!/usr/bin/ksh
# vi:set ts=8 sw=4 et sta:
#
# Author: Clark WANG <dearvoid at gmail.com>
#
#--------------------------------------------------------------------#

LOGFILE=/tmp/test.log
> $LOGFILE

function _debug
{
    echo "$*" >> $LOGFILE
}
alias debug='_debug "[${.sh.file}:$LINENO]"'

debug "This is a debug message"

cat $LOGFILE
