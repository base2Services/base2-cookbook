#!/bin/bash

if [[ $1 == 'used' && $2 == 'Percent' ]]; then
    AWK_CMD='{if(NR>1) { gsub("%","",$5); print $1 ":" $5 ":" } }'
elif [[ $1 == 'used' && $2 == 'Megabytes' ]]; then
    AWK_CMD='{if(NR>1) { print $1 ":" $3 ":" } }'
    DF_FLAG="-m"
elif [[ $1 == 'free' && $2 == 'Percent' ]]; then
    AWK_CMD='{if(NR>1) { gsub("%","",$5); print $1 ":" 100-$5 ":" } }'
elif [[ $1 == 'free' && $2 == 'Megabytes' ]]; then
    AWK_CMD='{if(NR>1) { gsub("%","",$4); print $1 ":" $4 ":" } }'
    DF_FLAG="-m"
else
    echo "Usage: get-free-disk-percent.sh [free|used] [Percent|Megabytes]"
    exit -1
fi


df $DF_FLAG --type btrfs --type  ext4 --type ext3 --type ext2 --type vfat --type iso9660 | awk "$AWK_CMD"