#!/bin/bash
#----------
# Generate directories per decenium for the .XEX/.CAR files in current directory (and move files there).
#
# NOTE: The Homesoft collection does not set the modification time to a usable value. Fandal properly sets it.

SRCDIR="${1:-../work/a8_fandal_cz/Binaries/Games}"
OUTDIR="${2:-../media/ATARI/ByYEAR/Fandal/Games}"

printf "Copying files from %s to %s...\n" "${SRCDIR}" "${OUTDIR}"

while IFS=$';' read -r src dst; do
    FY=${dst%%/*}
    if [ ! -d ${OUTDIR}/$FY ]; then
        mkdir -p "${OUTDIR}/$FY"
    fi
    #printf "%s. cp -a '%s' '%s'\n" "$FY" "$src" "$dst"
    cp -a "${src}" "${OUTDIR}/${dst}"
done < <( find "${SRCDIR}" -type f -name "*.[XxCc][EeAa][XxRr]" -printf "%p;%TY/%f\n" )
printf " ... DONE!\n"
