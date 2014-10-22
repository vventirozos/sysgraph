#!/bin/bash
source ../etc/sysgraph.conf

set -x
set -e

cat $tmpdir/mem-*.log | grep 'MemFree\|MemTotal\|Buffers\|Cached' | grep -v Swap | sed 'h;s/.*//;N;G;s/\n//g' | sed 'h;s/.*//;N;G;s/\n//g' > $tmpdir/tempfile

mf=$(cat $tmpdir/tempfile | sed -e "s/\s\{1,\}/ /g" | grep MemFree | awk '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == "MemFree:") print ++i;}}' | head -1)
mt=$(cat $tmpdir/tempfile | sed -e "s/\s\{1,\}/ /g" | grep MemTotal | awk '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == "MemTotal:") print ++i;}}' | head -1)
b=$(cat $tmpdir/tempfile | sed -e "s/\s\{1,\}/ /g" | grep Buffers | awk '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == "Buffers:") print ++i;}}' | head -1)
c=$(cat $tmpdir/tempfile | sed -e "s/\s\{1,\}/ /g" | grep Cached | awk '{len=split($0, a, " "); for(i=1;i<=len;i++){if (a[i] == "Cached:") print ++i;}}' | head -1)

cat $tmpdir/tempfile | awk -v mf=$mf -v mt=$mt -v b=$b -v c=$c '{print $2","($mt-$mf-$b-$c)}' > $tmpdir/output1.csv 

awk -F "," '{ tmp=($2)/(1024*1024) ; printf $1",%0.2f\n", tmp }' $tmpdir/output1.csv > $tmpdir/$output

#rm $tmpdir/output1.csv
sed -i "1s/^/date\tmem_used\n&/" $tmpdir/$output
