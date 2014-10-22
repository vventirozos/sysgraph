#!/bin/bash
source ../etc/sysgraph.conf
# $1 logs location
# $2 location to store parsed files
# $3 graph
output=output.csv
1=/home/vasilis/work/working_on/projects/logs/temp
2=/home/vasilis/work/working_on/projects/logs/temp
set -e
set -x

cut -f1,15 $1/pg_locks-*.log | sort | uniq -c | grep -v mode | awk {'print $3","$1","$5'} > $2/AllLocks.csv

if 	[ $3 = "access_share" ]
    then
    cat $2/AllLocks.csv | grep 'AccessShareLock' | awk {'print $1","$2'} > $2/$output
    rm $2/AllLocks.csv
    sed -i '1s/^/date,accessShareLock\n&/' $2/$output
elif	[ $3 = "row_exclusive" ]
    then
    cat $2/AllLocks.csv | grep 'RowExclusiveLock' | awk {'print $1","$2'} > $2/$output
    rm $2/AllLocks.csv
    sed -i '1s/^/date,rowExclusiveLock\n&/' $2/$output
elif	[ $3 = "share_lock" ]
    then
    cat $2/AllLocks.csv | grep 'ShareLock' | grep -v 'AccessShareLock' | awk {'print $1","$2'} > $2/$output
    rm $2/AllLocks.csv
    sed -i '1s/^/date,shareLock\n&/' $2/$output
elif	[ $3 = "exclusive_lock" ]
    then
    cat $2/AllLocks.csv | grep 'ExclusiveLock' | grep -v 'RowExclusiveLock' | awk {'print $1","$2'} > $2/$output
    sed -i '1s/^/date,exclusiveLock\n&/' $2/$output
    rm $2/AllLocks.csv
elif [ $3 = "all_share_locks" ]
    then
    cat $2/AllLocks.csv | grep 'AccessShareLock' | awk {'print $1","$2'} > $2/AccessShareLock.csv
    cat $2/AllLocks.csv | grep 'ShareLock' | grep -v 'AccessShareLock' | awk {'print $1","$2'} > $2/ShareLock.csv
    join -a1 -a2 -1 1 -2 1 -o 0 1.2 2.2 -e "0" $2/AccessShareLock.csv $2/ShareLock.csv | awk {'print $1","$2","$3'} > $2/$output
    rm $2/AllLocks.csv
    rm $2/ShareLock.csv
    rm $2/AccessShareLock.csv
    sed -i '1s/^/date,accessShareLock,shareLock\n&/' $2/$output
elif [ $3 = "all_exclusive_locks" ]
then
cat $2/AllLocks.csv | grep 'ShareLock' | grep -v 'AccessShareLock' | awk {'print $1","$2'} > $2/ShareLock.csv
cat $2/AllLocks.csv | grep 'AccessShareLock' | awk {'print $1","$2'} > $2/AccessShareLock.csv
join -a1 -a2 -1 1 -2 1 -o 0 1.2 2.2 -e "0" $2/AccessShareLock.csv $2/ShareLock.csv | awk {'print $1","$2","$3'} > $2/$output
rm $2/AllLocks.csv
rm $2/ShareLock.csv
rm $2/AccessShareLock.csv
sed -i '1s/^/date,rowExclusiveLock,exclusiveLock\n&/' $2/$output
elif	[ $3 = "shared_waiting" ]
    then
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep ShareLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/SLTemp.csv
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep AccessShareLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/ASLTemp.csv
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep ExclusiveLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/ELTemp.csv
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep RowExclusiveLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/RELTemp.csv
    join -a1 -a2 -1 1 -2 1 -o 0 1.2 2.2 -e "0" $2/ASLTemp.csv $2/SLTemp.csv | awk {'print $1","$2","$3'} > $2/$output
    rm $2/SLTemp.csv
    rm $2/ASLTemp.csv
    rm $2/ELTemp.csv
    rm $2/RELTemp.csv
    rm $2/AllLocks.csv
    sed -i '1s/^/date,accessShareLock,shareLock\n&/' $2/$output
elif	[ $3 = "exclusive_waiting" ]
    then
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep ShareLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/SLTemp.csv
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep AccessShareLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/ASLTemp.csv
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep ExclusiveLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/ELTemp.csv
    cut -f1,15,16 $1/pg_locks-*.log | grep -v mode | grep RowExclusiveLock | sort | uniq -c | awk '$6 == "f" {print $3","$1}' > $2/RELTemp.csv
    join -a1 -a2 -1 1 -2 1 -o 0 1.2 2.2 -e "0" $2/ASLTemp.csv $2/SLTemp.csv | awk {'print $1","$2","$3'} > $2/$output
    rm $2/SLTemp.csv
    rm $2/ASLTemp.csv
    rm $2/ELTemp.csv
    rm $2/RELTemp.csv
    rm $2/AllLocks.csv
    sed -i '1s/^/date,rowExclusiveLock,exclusiveLock\n&/' $2/$output
else echo "not implemented"
fi
