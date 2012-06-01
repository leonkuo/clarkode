#!/usr/bin/ksh
# vi:set ft=sh:
#
# Author: Clark WANG <dearvoid at gmail.com>
#
#--------------------------------------------------------------------#

PROGNAME=$0

function _echo
{
    printf '%s\n' "$*"
}

function usage
{
    cat << END
usage: $PROGNAME [option]... file...

options:
    -d, --debug         Debug mode
    -h, --help          Help
    -v, --verbose       Verbose mode
END

    exit $1
}

function parseargs
{
    typeset opt v

    [[ $# = 0 ]] && usage 1

    while getopts "[-][d:debug][h:help][v:verbose]" opt "$@"; do
        case $opt in
            d)   _echo --debug ;;
            h)   usage ;;
            v)   _echo --verbose ;;
            '?') exit 2 ;;
        esac
    done
    shift $((OPTIND - 1))

    for v in "$@"; do
        _echo "$v"
    done
}

parseargs "$@"
