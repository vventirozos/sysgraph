#!/bin/bash

# $1 logs location
# $2 location to store parsed files

set -x
set -e

cat $1/pg_stat_bgwriter-*.log |awk {'print $2","$10'}| sort > $2/output.csv
