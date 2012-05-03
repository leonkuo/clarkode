#!/usr/bin/python
# vi:set ts=8 sw=4 sta et:
#
# Author: Clark WANG <dearvoid @ gmail.com>
#
#--------------------------------------------------------------------#

import sys, os, os.path, getopt, commands, re

g = {
    "progname" : os.path.basename(sys.argv[0]),
    "man"      : '',
    "ps2pdf"   : '',
    "groff"    : '',
    "all"      : False,
    "sections" : '',
    "verbose"  : False,
    "showonly" : False,
    "topics"   : []
}

def debug(msg):
    if g["verbose"]:
        print '[debug] %s' % msg

def error(msg):
    print '[\033[0;31merror\033[0m] %s' % msg

def usage(exitcode = 0):
    print '''\
Usage: %s -h
       %s [-a | -s <secs>] [-v] NAME ...
       %s [-a | -s <secs>] [-v] [-w] NAME ...

    -a          Search all manual sections.
    -h, --help  Help
    -s, --sections=<secs>
                <secs> is a colon separated list of manual sections to
                search.
    -v, --verbose
                Verbose
    -w          Do not create PDF. Only show which file to use.

Report bugs to \033[1;35mClark WANG \033[0m<dearvoid @ gmail.com>.''' % (g['progname'], g['progname'], g['progname'])
    sys.exit(exitcode)

def getargs():
    try:
        opts, g['topics'] = getopt.getopt(sys.argv[1:], "ahs:vw",
                                          ['help', 'sections=', 'verbose'])
    except getopt.GetoptError, errmsg:
        usage(1)

    for o, a in opts:
        if o == '-a':
            g['all'] = True
        if o in ('-h', '--help'):
            usage(2)
        if o in ('-s', '--sections'):
            g['sections'] = a
        if o in ('-v', '--verbose'):
            g['verbose'] = True
        if o == '-w':
            g['showonly'] = True

    if g['all'] and g['sections']:
        usage(3)

    if not g['topics']:
        usage(4)

def findcmd(exes):
    for exe in exes:
        exepath = commands.getoutput("which %s 2> /dev/null" % (exe))
        if os.path.exists(exepath):
            return exepath
    return ''

def findcmds():
    cmds = [ ('man',    ['man']),
             ('groff',  ['groff']),
             ('ps2pdf', ['ps2pdf14', 'ps2pdf13', 'ps2pdf12', 'ps2pdf', 'pstopdf']) ]
    for (name, exes) in cmds:
        g[name] = findcmd(exes)
        if not g[name]:
            error(name.upper() + " not found")
            sys.exit(1)
        debug(name.upper() + ': ' + g[name])

def runcmd(cmd):
    debug(cmd)
    status, output = commands.getstatusoutput(cmd)
    if g['verbose'] and output:
        print output
    if status:
        debug("Command exited non-zero")
    return status

def is_solaris():
    status, output = commands.getstatusoutput('uname')
    if output == 'SunOS':
        return True
    else:
        return False

def man2pdf(topic):
    if not topic: return

    if is_solaris():
        man_w = '%s -l' % (g['man'])
    else:
        man_w = '%s -w' % (g['man'])

    tmpdir = '/tmp'

    if is_solaris():
        if len(g['sections']):
            man_w += ' -s ' + re.sub(':', ',', g['sections'])
    else:
        if g['all']:
            man_w += ' -a'
        elif len(g['sections']):
            man_w += ' -a -S' + g['sections']

    cmd = '%s -- %s 2> /dev/null' % (man_w, topic)
    fd = os.popen(cmd, 'r')
    nmanfile = 0
    for manfile in fd:
        nmanfile += 1
        manfile = manfile.strip()
        manfile = re.sub(' \(source:.*', '', manfile)
        manfile = re.sub('.*\(<-- (.*)\)', '\\1', manfile)
        manfile = re.sub('^(.*) \((.*)\)[ \t]+-M (.*)$', '\\3/man\\2//\\1.\\2', manfile)

        if not os.path.exists(manfile):
            error("File `%s' not found" % manfile)
            continue

        if g['showonly']:
            print topic + ': ' + manfile
            continue

        basename = os.path.basename(manfile)
        if manfile.endswith('.gz'):
            basename = re.sub('(.*)\.gz', '\\1', basename)
            cmd = 'gzip -dc %s > %s/%s' % (manfile, tmpdir, basename)
        elif manfile.endswith('.bz2'):
            basename = re.sub('(.*)\.bz2', '\\1', basename)
            cmd = 'bzip2 -dc %s > %s/%s' % (manfile, tmpdir, basename)
        else:
            cmd = 'cp -f %s %s' % (manfile, tmpdir)
        if runcmd(cmd): continue

        cmd = '%s -t -e -mandoc -Tps %s/%s > %s/%s.ps' \
              % (g['groff'], tmpdir, basename, tmpdir, basename)
        if runcmd(cmd): continue

        if g['ps2pdf'].endswith('/pstopdf'):
            cmd = '%s -o ./%s.pdf %s/%s.ps' \
                  % (g['ps2pdf'], basename, tmpdir, basename)
        else:
            cmd = '%s %s/%s.ps' % (g['ps2pdf'], tmpdir, basename)
        if runcmd(cmd): continue

        if os.path.exists(basename + '.pdf'):
            print "Created: %s.pdf" % (basename)
        else:
            error('Failed to create %s.pdf' % (basename))

        runcmd('rm -f %s/%s %s/%s.ps' % (tmpdir, basename, tmpdir, basename))

        if not g['all'] and not len(g['sections']):
            break
    else:
        if not nmanfile:
            error("Man page for `%s' not found" % topic)
        fd.close()

def main():
    getargs()
    findcmds()
    map(man2pdf, g['topics'])

main()
