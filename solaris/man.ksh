#!/usr/bin/ksh
# vi:set ts=8 sw=4 et sta:
#
# Author: Clark WANG <dearvoid at gmail.com>
#
#--------------------------------------------------------------------#

{
    g_sMyName=$(basename $0)
    g_sLogFile=~/tmp/$g_sMyName.log
    g_bVerbose=0

    g_cmdMan=/usr/bin/man
    g_gnuManPath=/usr/gnu/share/man/

    g_bAll=0
    g_bGNU=0
    g_bList=0
    g_secs=
    g_sTopic=
}

function startup
{
    typeset logDir=${g_sLogFile%/*}

    if [[ $( uname ) != SunOS ]]; then
        fatal "it's not solaris: $( uname )"
    fi

    mkdir -p $logDir

    return 0
}

function cleanup
{
    return 0
}

function usage
{
    typeset nExit=$1

    cat << END
Usage: $g_sMyName -h
       $g_sMyName -p ...
       $g_sMyName [-a | -s SECS ] [-l] [OPTION...] NAME

Options:
    -a          Show all manual pages matching NAME
    -g          Don't skip GNU manual pages under $g_gnuManPath
    -l          List all manual pages found
    -h          Help
    -p          Passthru to $g_cmdMan
    -s SECS     Specifies sections of the manual to search
    -v          Verbose mode

Report bugs to Clark WANG <dearvoid at gmail.com>.
END

    exit $nExit
}

function getargs
{
    typeset cOption

    OPTIND=1
    while getopts ':aglhps:v' cOption; do
        case $cOption in
            a)  g_bAll=1 ;;
            g)  g_bGNU=1 ;;
            h)  usage ;;
            l)  g_bList=1 ;;
            p)
            {
                shift

                LC_ALL=C $g_cmdMan "$@"
                exit
            };;
            s)  g_secs=$OPTARG ;;
            v)  g_bVerbose=1 ;;

            :)
            {
                fatal 2 "Option \`-$OPTARG' wants an argument"
            };;

            '?')
            {
                fatal 2 "Option \`-$OPTARG' not supported"
            };;
        esac
    done
    shift $((OPTIND - 1))

    if [[ $# != 1 ]]; then
        usage 2
    else
        g_sTopic=$1
    fi

    if [[ $g_bAll = 1 && -n $g_secs ]]; then
        fatal "-a and -s are exclusive"
    fi
}

function info
{
    print "+++ $*"
    print "+++ $*" >> $g_sLogFile
}

function debug
{
    print -- "--- $*" >> $g_sLogFile 2>&1
}

function verbose
{
    typeset msg="$*"

    print "... $msg" >> $g_sLogFile 2>&1

    if [[ $g_bVerbose -gt 0 ]]; then
        print "... $msg"
    fi
}

function warning
{
    print "??? $*"
    print "??? $*" >> $g_sLogFile
}

function error
{
    print "!!! $*"
    print "!!! $*" >> $g_sLogFile
}

function fatal
{
    typeset errno=1 msg

    if [[ -n $1 && -z ${1//[0-9]/} ]]; then
        errno=$1
        shift
    fi

    if [[ -n $1 ]]; then
        print "!!! $*"
        print "!!! $*" >> $g_sLogFile
    fi

    exit $errno
}

function main
{
    typeset mancmd="$g_cmdMan -l"
    typeset line manfile mandir
    typeset found=0
    typeset groffopt

    getargs "$@"

    if [[ $g_bAll = 1 ]]; then
        mancmd+=' -a'
    elif [[ -n $g_secs ]]; then
        mancmd+=" -s $g_secs"
    fi

    debug "$mancmd -- $g_sTopic"
    $mancmd -- $g_sTopic 2> /dev/null \
    | while read line; do
        print -- "$line" | sed -e 's@^\(.*\) (\(.*\))[ '$'\t'']\{1,\}-M \(.*\)$@\3/man\2/\1.\2@' | read manfile
        if [[ -f $manfile ]]; then
            debug "File: $manfile"
        else
            print -- "$line" | sed -e 's@^\(.*\) (\(.*\))[ '$'\t'']\{1,\}-M \(.*\)$@\3/man\2/\1@' | read manfile
            if [[ -f $manfile ]]; then
                debug "File: $manfile"
            else
                error "File: $manfile not found"
                continue
            fi
        fi

        found=1

        if [[ $g_bList = 1 ]]; then
            print "$g_sTopic: $manfile"
            continue
        fi

        if [[ $g_bGNU = 0 && $manfile == $g_gnuManPath* ]]; then
            info "Skipping GNU man page: $manfile"
            continue
        fi

        if [[ $manfile == */man/man*/* ]]; then
            mandir=${manfile%/man*/*}
            debug "mandir: $mandir"
            if [[ -d $mandir ]]; then
                groffopt="-I $mandir"
            fi
        fi
        LC_ALL=C groff $groffopt -t -e -mandoc -Tascii $manfile | less -imRSs

        if [[ $g_bAll = 0 && -z $g_secs ]]; then
            break
        fi
    done

    if [[ $found = 0 ]]; then
        error "No manual entry for $g_sTopic"
    fi
}

{
    startup

    main "$@"

    cleanup
}
