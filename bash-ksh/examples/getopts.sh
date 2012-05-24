#
# vi:set ts=8 sw=4 et sta:
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
usage: $PROGNAME [-a] [-b arg] [-h] file...
END

    exit $1
}

function parseargs
{
    typeset opt v

    [[ $# = 0 ]] && usage 1

    while getopts ":ab:h" opt "$@"; do
        case $opt in
            a)   _echo -$opt ;;
            b)   _echo -$opt $OPTARG ;;
            h)   usage ;;
            :)   _echo "! option -$OPTARG wants an argument" ;;
            '?') _echo "! unkown option -$OPTARG" ;;
        esac
    done
    shift $((OPTIND - 1))

    for v in "$@"; do
        _echo "$v"
    done
}

#
# Examples:
#
#  $ parseargs -h
#  $ parseargs -x
#  $ parseargs -b
#  $ parseargs -b bb -a hello world
#
parseargs "$@"
