#!/bin/bash
source ../etc/sysgraph.conf

# $1 logs location
# $2 location to store parsed files

set -x
set -e

cat $1/loadavg-*.log |awk {'print $2","$5","$6","$7'}| sort > $2/$output
