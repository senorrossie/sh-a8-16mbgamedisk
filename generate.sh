#!/bin/bash

### DEBUG
#set -xv

### Settings
source config

let MAXSIZE=16360

if [ '$( ls -1 "${FANDAL}*" )' == '' ]; then
    printf "Unable to locate the fandal archive in %s*!" "${FANDAL}"
    printf "You can manually download and extract it (an archiver that works is 7zip) to the work directory.\n"
    exit 1
fi

function prep_disks() {
    let TD=0            # Total disks
    let TF=0            # Total files
    let TF=0            # Total size
    let SIZE=0

    OLDIFS=$IFS
    for TYPE in GAME DEMO; do
        printf "Processing Fandal's %s collection in %s* (Destination: %s)...\n" "${TYPE}" "${FANDAL}" "$ATRDIR"

        # Create base destination directory
        OUTDIR="${ATRDIR}${TYPE}"
        if [ ! -d "${OUTDIR}" ]; then
            mkdir -p "${ATRDIR}"
        fi

        let C=1             # DISK
        let N=0             # Number of files
        let SIZE=0

        IFS=$'\n'
        for BIN in `find ${FANDAL}*/Binaries/Games/ -type f -name "*.xex"`; do
            let N++
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
            fi
            DST=`echo $BIN | rev | cut -d / -f 1,2 | rev`
            SUBDIR=`echo $DST | cut -d / -f 1`
            if [ ! -d "${OUTDIR}${C}/${SUBDIR}" ]; then
                mkdir -p ${OUTDIR}${C}/${SUBDIR}
            fi

            cp -a "$BIN" "$OUTDIR$C/$DST"
        done
        let TS=$((TS + SIZE))
        let TD=$((TD + 1))
        let TF=$(($TF + $N))
        printf " - Disk: %s\t(Size: %s, Files: %s)\n" "$C" "$SIZE" "$N"
    done
    IFS=$OLDIFS

    printf "\nCreated %s atr image directories, with %s files. Total size: %s\n" "$TD" "$TF" "$TS"
}

function gen_disks() {
    for DISK in `ls -1 ${ATRDIR}`; do
        printf "Creating atr for %s\n" "$DISK"
        if [ ! -x tools/dir2atr ]; then
            printf "Unable to execute dir2atr from the tools directory.\n"
        fi
        tools/dir2atr -d -b ${MYPICO} -P 65535 ${ATRDIR}${DISK}.atr ${ATRDIR}${DISK}
    done
}

#prep_disks
gen_disks