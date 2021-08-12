#!/bin/bash
# ---------
#
# Script that copies the fandal and homesoft archives to the fat space of a CF card named ATARI
# Want to change the destination? Modify the CFMOUNT value in the script, or supply a value on the commandline, eg:
#  CFMOUNT="/media/user/MYCFCARD" ./copy2cf.sh

function do_Fandal() {
	for TYPE in Binaries Images; do
		case $TYPE in
			I*)
				DEST="${CFMOUNT}/atr/Fandal/"
				FTYPE="*.atr"
				SOURCE="${SBASE}/Images"
				;;
			B*)
				DEST="${CFMOUNT}/xex/Fandal/"
				FTYPE="*.xex"
				SOURCE="${SBASE}/Binaries"
				;;
		esac

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
	done
}

function do_Homesoft() {
	for TYPE in Binaries Images; do
		case $TYPE in
			I*)
				DEST="${CFMOUNT}/atr/Homesoft/"
				FTYPE="*.atr"
				SOURCE="${SBASE}/"
				;;
			B*)
				DEST="${CFMOUNT}/xex/Homesoft/"
				FTYPE="*.xex"
				SOURCE="${SBASE}/"
				;;
		esac

		echo "Copying ${TYPE}(${FTYPE}) from ${SOURCE} to ${DEST}..."
		for BIN in `find ${SOURCE} -type f -name "${FTYPE}" | sort -n`; do
			DFILE=`echo $BIN | rev | cut -d / -f 1,2 | rev`
			DST=`echo $DFILE | cut -d / -f 1`
			if [ ! -d "${DEST}/${DST}" ]; then
				mkdir -p "${DEST}/${DST}"
			fi

			if [ ! -e "$DEST$DFILE" ]; then
				#echo "cp \"$BIN\" \"$DEST$DFILE\""
				cp "$BIN" "$DEST$DFILE"
			fi
		done
	done
}

### Main
SBASE=${SBASE:-"../work/a8_fandal_*"}
CFMOUNT=${CFMOUNT:-"../media/ATARI"}
IFS=$'\n'
do_Fandal

SBASE=${SBASE:-"../work/Homesoft Collection"}
CFMOUNT=${CFMOUNT:-"../media/ATARI"}
IFS=$'\n'
do_Homesoft
