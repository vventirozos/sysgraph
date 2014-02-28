#!/bin/bash
source ../etc/sysgraph.conf

set -x
set -e

response=$(cat $1/iostat-*.log | sed -e "s/\s\{1,\}/ /g" | grep $4 | awk -v var=$4 '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == var) print i;}}' | head -1)
wait=$(cat $1/iostat-*.log | sed -e "s/\s\{1,\}/ /g" | grep $5 | awk -v var=$5 '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == var) print i;}}' | head -1)
cat $1/iostat-*.log | grep $3 | awk -v response=$response -v wait=$wait  '{print $2","$response","$wait}'> $2/output.csv
sed -i "1s/^/date,$4,$5\n&/" $2/output.csv