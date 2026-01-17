#!/bin/bash

# 1. Compiles our modified version of h89ldr2 

# 2. Tests it using various offsets.

# If it succeeds, then there was no reason to use the weird nested
# 8-bit loops in ALGNR2. If it fails, then there is something more I
# am missing that I want to understand.

# The byte used for offsets is 'v' (0x76) which is the 8080 HLT
# instruction. It is placed at the end of the file since H89TRANS
# sends the file backwards-style ("WATCH MINE!")


asmx -b2329H -e -w -C8080 looptest.asm || exit 1
mv looptest.asm.bin looptest.bin
ln -s looptest.bin H89LDR2.BIN

size=$(stat -c %s looptest.bin)

if (( size < 818 )); then
    echo "Adding $((818-size)) nulls to make looptest.bin filesize equal 818"
    for (( i=size; i<818; i++)); do
	printf '\x00' >> looptest.bin
    done
fi

prev=looptest.bin
for (( i=1; i<=8; i++)); do
    new=looptest+$i.bin
    cp $prev  $new
    printf 'v' >> $new
    echo Created $new with size $(stat -c %s $new)
    prev=$new
done



