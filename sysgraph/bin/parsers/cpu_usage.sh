#!/bin/bash
source ../etc/sysgraph.conf
set -x
set -e

usr=$(cat $tmpdir/mpstat-*.log | sed -e "s/\s\{1,\}/ /g" | grep $usr | awk -v var=$usr '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == var) print i;}}' | head -1)
sys=$(cat $tmpdir/mpstat-*.log | sed -e "s/\s\{1,\}/ /g" | grep $sys | awk -v var=$sys '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == var) print i;}}' | head -1)
iowait=$(cat $tmpdir/mpstat-*.log | sed -e "s/\s\{1,\}/ /g" | grep $iowait | awk -v var=$iowait '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == var) print i;}}' | head -1)
cat $tmpdir/mpstat-*.log | awk {'print $2","$8","$10","$11'} | grep -v 'Linux\|usr\|CPU' | awk 'BEGIN {FS=","} $2!="" {print}' > $tmpdir/$output
sed -i "1s/^/date//" $tmpdir/$output