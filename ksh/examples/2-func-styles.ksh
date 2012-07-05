#!/usr/bin/ksh
# vi:set ts=8 sw=4 et sta:
#
# Author: Clark WANG <dearvoid at gmail.com>
#
#--------------------------------------------------------------------#

alias echo='print -r -'

SET_VAR()
{
    typeset var=$1
}

print_var_1()
{
    echo var=$var
}

function print_var_2
{
    echo var=$var
}

function f1
{
    set_var value1

    print_var_1
    print_var_2
}

f1

echo ----------------

print_var_1
print_var_2

echo ----------------

set_var value2
print_var_1
print_var_2
