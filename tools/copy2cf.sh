#!/bin/bash
# ---------
#
# Script that copies the fandal archive to the fat space of a CF card named ATARI
OLDIFS=$IFS
SBASE="../work/a8_fandal_cz_december_2019"
CFMOUNT="/media/$USER/ATARI"
IFS=$'\n'
for TYPE in Binaries Images; do
	case $TYPE in
		I*)
			DEST="${CFMOUNT}/atr/fandal/"
			FTYPE="*.atr"
			SOURCE="${SBASE}/Images"
			;;
		B*)
			DEST="${CFMOUNT}/xex/fandal/"
			FTYPE="*.xex"
			SOURCE="${SBASE}/Binaries"
			;;
	esac

	echo "Copying ${TYPE}(${FTYPE}) from ${SOURCE} to ${DEST}..."
	for BIN in `find ${SOURCE} -type f -name "${FTYPE}"`; do
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