#!/bin/bash

shopt -s expand_aliases

alias free_mem="cat /proc/meminfo | grep MemFree | awk '{ print \$2  }'"
alias avail_mem="cat /proc/meminfo | grep MemAvailable | awk '{ print \$2 }'"
alias total_mem="cat /proc/meminfo | grep MemTotal | awk '{ print \$2 }'"
alias real_used_mem="expr `total_mem` - `avail_mem`"

if [ $1 == 'Free' ]; then
    VAL=`free_mem`
fi

if [ $1 == 'ActualFree' ]; then
    VAL=`avail_mem`
fi

if [ $1 == 'UsedPercent' ]; then
    VAL=$(echo "scale=2; `real_used_mem` / `total_mem` * 100" | bc)
fi

if [ $1 == 'Total' ]; then
     VAL=`total_mem`
fi

echo "$VAL:"
