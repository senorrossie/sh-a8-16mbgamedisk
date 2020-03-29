#!/bin/bash

### DEBUG
#set -xv

### Settings
source config 2>/dev/null

# Defaults if unset
FANDAL=${FANDAL:-"work/a8_fandal_cz"}
ATRDIR=${ATRDIR:-"work/16M/"}
MYPICO=${NYPICO:-"MyPicoDos406S1"}
let MAXSIZE=${MAXSIZE:-16360}
let FMAX=${FMAX:-62}

# Counters
let TD=0            # Total disks
let TF=0            # Total files
let TF=0            # Total size

# Store IFS
OLDIFS=$IFS

# Sanity check
if [ '$( ls -1 "${FANDAL}*" )' == '' ]; then
    printf "Unable to locate the fandal archive in %s*!" "${FANDAL}"
    printf "You can manually download and extract it (an archiver that works is 7zip) to the work directory.\n"
    exit 1
fi
if [ ! -e "${ATRDIR}" ]; then 
    printf "Destination directory %s does not exist. Please create it first!\n" "${ATRDIR}"
    exit 1
fi

function prep_disks() {
    let C=1             # DISK
    let N=0             # Number of files
    let D=0             # Directory #
    let DE=0            # Directory Entry
    let SIZE=0

    OLDDIR=""
    OUTDIR="${ATRDIR}${TYPE}"
    PREVIOUS=""
    XTRA=""

    IFS=$'\n'
    for BIN in `find ${SDIR} -type f -name "*.xex" | sort -n`; do
        let N++
        let DE++

        DST=`echo $BIN | rev | cut -d / -f 1 | rev`
        SUBDIR=`echo $BIN | rev | cut -d / -f 2 | rev`
        if [ x$SUBDIR != x$OLDDIR ]; then
            # New letter
            OLDDIR=${SUBDIR}
            let D=0     # Directory #
            let DE=1    # Directory entry
            XTRA=""
        fi

        if [ $DE -eq $FMAX ]; then
            let D++
            XTRA="${DST:1:1}"
            XTRA=${XTRA^^}
            XTRA=${XTRA// /_}
            if [ -e "$OUTDIR$C/$SUBDIR$XTRA" ]; then
                XTRA="${DST:1:1}$D"
                XTRA=${XTRA^^}
                XTRA=${XTRA// /_}
            fi
            let DE=1
        fi

        FSIZE=$(du "${BIN}" | awk '{print $1}')
        let SIZE=$(($SIZE + $FSIZE))
        if [ $SIZE -ge $MAXSIZE ]; then
            let DISKSIZE=$(($SIZE-$FSIZE))
            let TS=$((TS + DISKSIZE))
            printf " - Disk: %s\t(Size: %s, Files: %s)\n" "$C" "$DISKSIZE" "$N"
            let C++
            let TD=$((TD + 1))
            let SIZE=${FSIZE}
            let TF=$(($TF + $N - 1))
            let N=1
            let D=0
            let DE=0
        fi

        if [ ! -d "$OUTDIR$C/$SUBDIR$XTRA" ]; then
            mkdir -p $OUTDIR$C/$SUBDIR$XTRA
        fi

        #echo $DE\) \"$BIN\" \"$OUTDIR$C/$SUBDIR$XTRA/$DST\"
        if [ ! -e "$OUTDIR$C/$SUBDIR$XTRA/$DST" ]; then
            cp -a "$BIN" "$OUTDIR$C/$SUBDIR$XTRA/$DST"
        fi
    done
    let TS=$((TS + SIZE))
    let TD=$((TD + 1))
    let TF=$(($TF + $N))
    printf " - Disk: %s\t(Size: %s, Files: %s)\n" "$C" "$SIZE" "$N"
}

function gen_disks() {
    for DISK in `ls -1 ${ATRDIR} | grep -v atr$`; do
        printf " -> Creating atr for %s\n" "$DISK"
        if [ ! -x tools/dir2atr ]; then
            printf "Unable to execute dir2atr from the tools directory.\n"
            break
        fi
        WORKDIR=`pwd`
        TOOLDIR=`dirname ${WORKDIR}/tools/dir2atr`
        cd ${ATRDIR}${DISK}
        ${TOOLDIR}/dir2atr -d -b ${MYPICO} -P 65535 ../${DISK}.atr .
        cd -
    done
}

### Main
for TYPE in GAME DEMO; do
    case $TYPE in
        GAME)
            SDIR="${FANDAL}*/Binaries/Games"
            ;;
        DEMO)
            SDIR="${FANDAL}*/Binaries/Demos"
            ;;
    esac
    printf "Processing Fandal's %s collection in %s* (Destination: %s)...\n" "${TYPE}" "${SDIR}" "$ATRDIR"
    prep_disks
    printf "\nCreated %s atr image directories, with %s files. Total size: %s\n\n" "$TD" "$TF" "$TS"
done

gen_disks