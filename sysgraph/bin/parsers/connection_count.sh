#!/bin/bash
source ../etc/sysgraph.conf

# $1 logs location
# $2 location to store parsed files

set -x
set -e

cat $1/pg_stat_activity-*.log | awk {'print $2'} | sort | uniq -c | awk {'print $2","$1'} > $2/$output
sed -i "1s/^/date,count\n&/" $2/$output