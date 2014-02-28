#!/bin/bash
source ../etc/sysgraph.conf

# $1 logs location
# $2 location to store parsed files
# $3 disk name
# $4 column name
# $5 type

set -x
set -e

col=$(echo $4 | sed "s/\//p/g")
pos=$(cat $tmpdir/iostat-*.log | sed -e "s/\s\{1,\}/ /g" | grep $4 | awk -v var=$4 '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == var) print i;}}' | head -1)
cat $tmpdir/iostat-*.log | grep $3 | awk -v position=$pos '{print $2","$position}'> $tmpdir/output.csv
sed -i "1s/^/date\t$col\n&/" $tmpdir/output.csv
