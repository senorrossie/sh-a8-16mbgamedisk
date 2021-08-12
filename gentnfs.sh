#!/bin/bash

### DEBUG
#set -xv

function do_Copy() {
    IFS=$'\n'
    echo "Copying ${TYPE}(${FTYPE}) from ${SOURCE} to ${DEST}..."
    for BIN in `find ${SOURCE} -type f -name "${FTYPE}" | sort -n`; do
        DFILE=`echo $BIN | rev | cut -d / -f 1,2,3 | rev`
        DST=`echo $DFILE | cut -d / -f 1,2`
        if [ ! -d "${DEST}/${DST}" ]; then
            mkdir -p "${DEST}/${DST}"
        fi

        if [ ! -e "$DEST$DFILE" ]; then
            cp "$BIN" "$DEST$DFILE"
        fi
    done
}

function do_Copy_Alphabetical() {
    IFS=$'\n'
    while IFS= read -r -d $'\0' src; do
        FA=${src##*/}
        FA=${FA:0:1}
        if [ "`echo $FA | grep [0-9]`" != "" ]; then
            FA="0-9"
        fi
        if [ ! -d "${CFMOUNT}/${FA^}" ]; then
            mkdir -p "${CFMOUNT}/${FA^}"
        fi
        #printf "%s. cp -a '%s' '%s'\n" "${FA^}" "${src}" "${CFMOUNT}/${FA^}"
        cp -a "${src}" "${CFMOUNT}/${FA^}"
    done < <( find ${SBASE} -type f -name "*.[XxAa][EeTt][XxRr]" -print0 | sort -zn )
    #printf " ... DONE!\n"
}

function do_Copy_Annual() {
    while IFS=$';' read -r src dst; do
        FY=${dst%%/*}
        if [ ! -d ${CFMOUNT}/$FY ]; then
            mkdir -p "${CFMOUNT}/$FY"
        fi
        #printf "%s. cp -a '%s' '%s'\n" "$FY" "$src" "${CFMOUNT}/$dst"
        cp -a "${src}" "${CFMOUNT}/${dst}"
    done < <( find "${SBASE}" -type f -name "*.[XxCcAa][EeAaTt][XxRr]" -printf "%p;%TY/%f\n" )
    #printf " ... DONE!\n"
}

function checkArchive() {
    let current=0
    md5src=$( echo $1 | rev | cut -d . -f2- | rev )
    if [ -e $md5src ]; then
        md5sum -c $md5src
        if [ $? -gt 0 ]; then
            # md5 mismatch, newer file downloaded
            echo 1
        else
            echo 0
        fi
    else
        # md5 unknown, assuming newer file was downloaded
        echo 1
    fi
}
function extractArchive() {
    md5sum work/$myarc.zip > work/$myarc.md5
    mv work/$myarc.zip work/$myarc-current.zip
    7z x -owork/$workdir work/$myarc-current.zip
}

### Settings
source cfgtnfs 2>/dev/null

# Defaults if unset
TNFSDIR=${TNFSDIR:-"/mnt/samba/nas4free/public/tnfs/atari/archives"}

# Store IFS
OLDIFS=$IFS

# Sanity check
if [ '$( ls -1 "${TNFSDIR}*" )' == '' ]; then
    printf "Unable to locate the tnfs base directory %s*!" "${TNFSDIR}"
    exit 1
fi

# Dump Fandal
myarc="fandal"
tools/getarchive.sh http://a8.fandal.cz work/$myarc.zip  ;# Get Fandal
let res=$( checkArchive work/$myarc.zip )
if [ $res -gt 0 ]; then
    workdir="a8_fandal_cz_current"
    rm -rf work/$workdir
    extractArchive
    # Alphabetical
    CFMOUNT="$TNFSDIR/Fandal/Alphabetical" SBASE="work/a8_fandal_cz_current" do_Copy
    # By Year
    for SRCDIR in Binaries/Games Binaries/Demos Images/Games Images/Demos; do
        case $SRCDIR in
            B*)
                CFMOUNT="$TNFSDIR/Fandal/ByYear/xex/${SRCDIR##*/}" SBASE="work/a8_fandal_cz_current/$SRCDIR" do_Copy_Annual
                #echo "$SRCDIR"
                ;;
            I*)
                CFMOUNT="$TNFSDIR/Fandal/ByYear/atr/${SRCDIR##*/}" SBASE="work/a8_fandal_cz_current/$SRCDIR" do_Copy_Annual
                #echo "$SRCDIR"
                ;;
        esac
    done
fi

# Dump HomeSoft
myarc="homesoft-exe"
tools/getarchive.sh \
    http://www.mushca.com/f/atari/index.php?dl=FAF \
    work/$myarc.zip \
    http://www.mushca.com/f/atari/index.php?idx=0 ;# Get Homesoft
let res=$( checkArchive work/$myarc.zip )
if [ $res -gt 0 ]; then
    workdir=""
    rm -rf work/Homesoft*
    extractArchive
    CFMOUNT="$TNFSDIR/Homesoft/" SBASE="work/Homesoft Collection" do_Copy
fi

# Dump RastaConversion
CFMOUNT="$TNFSDIR/RastaConversions/" SBASE="work/Rasta Images" do_Copy_Alphabetical
