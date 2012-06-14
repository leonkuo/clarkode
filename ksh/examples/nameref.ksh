#!/usr/bin/ksh
# vi:set ts=8 sw=4 et sta:
#
# Author: Clark WANG <dearvoid at gmail.com>
#
#--------------------------------------------------------------------#

function toupper
{
    typeset -n ref=$1
    typeset -u upper=$ref

    ref=$upper
}

v=hello
echo $v

HELLO=world
echo $HELLO

toupper v
echo $v
toupper $v
echo $HELLO
