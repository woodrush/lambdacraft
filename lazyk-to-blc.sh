#!/bin/bash
set -e


file=$1
wrapper=$2

if [ -z "$wrapper" ]; then
    wrapper="./wrapper.blc"
fi



code=$(cat $file | tr -d "\n")

code=$(printf $code | sed s/\`/01/g)
code=$(printf $code | sed s/s/00000001011110100111010/g)
code=$(printf $code | sed s/k/0000110/g)
code=$(printf $code | sed s/i/0010/g)


sed -f - $wrapper << EOF
s/\\[program\\]/$code/g
EOF