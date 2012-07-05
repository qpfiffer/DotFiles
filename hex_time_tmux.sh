#!/bin/bash

times=( `%H` `%M` `%S` )
size=${#times[@]}
last_item=${times[$size-1]}
printf '0x' $last_item # Print the starting chars
for i in ${times[@]} 
do
    printf '%02X' $(( 10#$i ))
    if [ "$last_item" != "$i" ]; then
       printf ':'
    fi
done
