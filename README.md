# Atari 8-bit 16Mb gamedisk creator

## About
In the past there was a 16Mb disk compiler for windows... Now there's one for Linux.

## Goal
  - Dump the [fandal archive](http://a8.fandal.cz/) and create one or more 16Mb atr's containing the full binary(!) archive.

## Requirements

### AtariSIO / dir2atr

From [HiassofT's Atari 8bit world](https://www.horus.com/~hias/atari/) download the AtariSIO archive and compile it.
Ubuntu users may need to install the libncurses dependencies: ```apt install libncurses5 libncurses5-dev```
Copy the *dir2atr* binary to the *tools* directory of this script.

## Usage

Modify the supplied *config* file to suit your needs:\
**MAXSIZE** needs to leave some room for the loader and longfiles text files. The default value of **16360** should be safe.\
**MYPICO** refers to the boot image supported by *dir2atr*, part of the atari tools programs supplied by AtariSIO. Variants are listed in the *README-tools* text file that is part of the AtariSIO package.

Create the directory *work/16M*, if it is not there yet. If it is, make sure the directory is empty to avoid issues at a later stage.

Download the [fandal archive](http://a8.fandal.cz/) and extract it into the 'work' directory (preferably use a compatible archiver, like 7zip. As the archive is large and contains long filenames, some with special characters, not all archivers cope with its contents). After extracting the archive, the directory *work* should contain 2 entries, eg:\
16M\
a8_fandal_cz_december_2019
You are now ready to run the script *./generate.sh* which will generate 5 (at the moment) disk images (atr) for the Games in the fandal archive and five for the Demos. Move them to your storage medium of choice (SIDE2, IDE+, MyIDE, MyIDE][, etc.)
