#!/bin/bash
#----------
# Generate alphabetical directories for the .ATR/.XEX/.CAR files in current directory (and move files there).
printf "Processing... "
while IFS= read -r -d $'\0' FILE; do
    LETTER=${FILE##*/}
    LETTER=${LETTER:0:1}
    if [ "`echo $LETTER | grep [0-9]`" != "" ]; then
        LETTER="0-9"
    fi
    if [ ! -d "${LETTER^}" ]; then
        mkdir "${LETTER^}"
    fi
    printf "%s " "${LETTER^}"
    #echo "mv \"${FILE}\" \"${LETTER^}\""
    mv "${FILE}" "${LETTER^}"
done < <( find . -type f -name "*.[AaXxCc][TtEeAa][XxRr]" -print0 | sort -zn )
printf " ... DONE!\n"
