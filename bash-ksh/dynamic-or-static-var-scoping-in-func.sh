# vi:set ft=sh:
#
# Refs: http://lists.gnu.org/archive/html/bug-bash/2012-04/msg00213.html

var=global

function foo
{
    echo foo: $var
}

function bar
{
    typeset var=bar-local

    foo
}

foo
bar
