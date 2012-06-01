#!/bin/bash
# vi:set ts=8 sw=4 et sta:
#
# This file echoes a bunch of color codes to the terminal to demonstrate
# what's available. Each line is the color code of one foreground color,
# out of 17 (default + 16 escapes), followed by a test use of that color
# on all nine background colors (default + 8 escapes).
#

ESC=$'\033'
text='  gYw  '

echo
echo  "       default   40m     41m     42m     43m     44m     45m     46m     47m"

# foreground colors
for FG in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
          '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
          '  36m' '1;36m' '  37m' '1;37m';
do
    printf " $FG $ESC[$FG$text"
    FG=${FG// /}

    # background colors
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
        printf " $ESC[$FG$ESC[$BG$text$ESC[0m"
    done

    echo
done
echo
