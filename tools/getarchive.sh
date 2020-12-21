#!/bin/bash
###########
## Fandal
#  - homepage: http://a8.fandal.cz (Check for .zip file)
#
## Homesoft
# Checks for referrer:
#     curl -e http://www.mushca.com/f/atari/index.php?idx=0 -vv http://www.mushca.com/f/atari/index.php?dl=FAF -o homesoft-exe.zip
#     curl -e http://www.mushca.com/f/atari/index.php?idx=1 -vv http://www.mushca.com/f/atari/index.php?dl=FAI -o homesoft-atr.zip
#  Archive: http://www.mushca.com/f/atari/index.php?dl=FAI (Should output Homesoft Collection (Archive).zip) - ATRs
# Homesoft: http://www.mushca.com/f/atari/index.php?dl=FAF (Should output Homesoft Collection.zip) - EXEs (+ disk only ATRs)

MYURL="$1"
MYFILE="/tmp/.archive.html"
MYARCHIVE="$2"
MYREFERER="$3"

function _usage(){
    printf "\nUsage %s:\n" "$0"
    printf " %s [URL] [OUTFILE] <REFERER>\n" "$0"
    printf "\nExamples:\n"
    printf "Dump the Fandal archive to fandal.zip:\n %s http://a8.fandal.cz work/fandal.zip\n" "$0"
    printf "Dump the HomeSoft exe archive to homesoft-exe.zip:\n %s http://www.mushca.com/f/atari/index.php?dl=FAF ../work/homesoft-exe.zip http://www.mushca.com/f/atari/index.php?idx=0\n" "$0"
    printf "Dump the HomeSoft atr archive to homesoft-atr.zip:\n %s http://www.mushca.com/f/atari/index.php?dl=FAI work/homesoft-atr.zip http://www.mushca.com/f/atari/index.php?idx=1\n\n" "$0"

    exit
}

function _getHomepage(){
    FANDAL=""
    TURL=$1
    TFILE=${2:-$MYFILE}
    if [ "$TURL" == "" ]; then
        break
    else
        printf "Fetching list from %s... " "$TURL"
        curl -# "$TURL" -o $TFILE
        printf "done!\n"
    fi
    FANDAL=$( grep "http://a8.fandal.cz/files/a8_fandal_cz" $TFILE  | cut -d\" -f 2 )
    if [ "$FANDAL" != "" ]; then
        export MYURL="$FANDAL"
    fi
}

function _getArchive() {
    TURL=$1
    TARC=${2:-$MYARCHIVE}   ;#ARCHIVE=${FANDAL##h*/}
    TREF=$3
    if [ "$TURL" == "" ]; then
        break
    else
        if [ "$TREF" != "" ]; then
            TREF=" -e $TREF"
        fi
        printf "Downloading %s from %s (Referer: %s)\n" "${TARC}" "${TURL}" "${TREF:-NA}"
        curl -# ${TREF} ${TURL} -o ${TARC}
    fi
}

# Main
if [ "$1" == "" ] || [ "$2" == "" ]; then
    _usage
fi

# Check for zip
_getHomepage ${MYURL} ${MYFILE}
# Download archive
_getArchive ${MYURL} ${MYARCHIVE} ${MYREFERER}
