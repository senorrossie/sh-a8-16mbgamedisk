#!/bin/bash
#----------
# Generate a csv file from all .XEX files - and their md5 hash - in current directory (and below).
while IFS= read -r -d $'\0' FILE; do
    md5sum "${FILE}" | awk '{print $1 "," $2}'
done < <( find . -type f -name "*.[Xx][Ee][Xx]" -print0 ) > md5.csv