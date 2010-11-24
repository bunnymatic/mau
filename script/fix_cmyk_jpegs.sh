#!/bin/bash

IDENTIFY="/usr/local/bin/identify"
GREP="/usr/bin/grep"
for f in `find . -name '*.jpg' -print`; do
    img=`$IDENTIFY -format '%r' $f | $GREP -i rgb`
    if [ ! $img ]; then 
        echo -n .
        `convert -colorspace RGB $f $f`
    fi
done

for f in `find . -name '*.JPG' -print`; do
    img=`$IDENTIFY -format '%r' $f | $GREP -i rgb`
    if [ ! $img ]; then 
        echo -n .
        `convert -colorspace RGB $f $f`
    fi
done
