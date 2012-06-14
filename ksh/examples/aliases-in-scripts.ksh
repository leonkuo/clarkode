#!/usr/bin/ksh
# vi:set ts=8 sw=4 et sta:
#
# Author: Clark WANG <dearvoid at gmail.com>
#
#--------------------------------------------------------------------#

LOGFILE=/tmp/test.log
> $LOGFILE

function _error
{
    echo "$*" >> $LOGFILE
}
alias error='_error "[${.sh.file}:$LINENO]"'

error "This is an error message"

cat $LOGFILE
