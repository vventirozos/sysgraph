#!/bin/bash
echo "Reading config...." >&2
source ../etc/sysgraph.conf
function help {
echo "usage: ./sysgraph.sh <date> <graph type> <limit>"
echo "example: ./sysgraph.sh 2013-10-22 cpu_load"
echo "currently available graphs :"
echo ""
echo "cpu_load"
echo "locks"
echo "load_avg"
echo "io_read"
echo "io_write"
echo "io_wait"
echo "mem_used"
echo "active_conn"
echo ""
}
if test $# -ne 3; then
	help
	exit 0
fi
limit1=$3
#
# Following function defines the filenames that script should use
#
function _property {
if [ $graph = "cpu_load" ]
	then file_pattern="mpstat"
	title="cpu load report for $date"
	xlabel="time"
	ylabel="load"
	limit=$limit1
	plot_command="plot '$tmpdir/$output' using 1:2 title '%user' with lines ls 2 , '$tmpdir/$output' using 1:3 title '%system' with lines ls 3,'$tmpdir/$output' using 1:4 title '%iowait' with lines ls 1"
elif [ $graph = "load_avg" ]
	then file_pattern="loadavg"
	title="load average report for $date"
	xlabel="time"
	ylabel="load"
	limit=$limit1  
	plot_command="plot '$tmpdir/$output' using 1:2 title '1min avg' with lines ls 1 , '$tmpdir/$output' using 1:3 title '5min avg' with lines ls 3,'$tmpdir/$output' using 1:4 title '15min avg' with lines ls 4"
elif [ $graph = "locks" ]
        then file_pattern="cooked"
	title="Access Share Locks report for $date"
	xlabel="time"
	ylabel="locks"
	limit=$limit1   
	plot_command="plot '$tmpdir/$output' using 1:2 title 'Access Share Locks' with lines ls 1"
elif [ $graph = io_read ]
	then
	title="io read report for $date"
	xlabel="time"
	ylabel="KB"
	limit=$limit1
	file_pattern="iostat"
	plot_command="plot '$tmpdir/$output' using 1:2 title 'Reads KB' with lines ls 1"		                  
elif [ $graph = io_write ]
	then file_pattern="iostat"
	title="io write report for $date"
	xlabel="time"
	ylabel="KB"
	limit=$limit1
    plot_command="plot '$tmpdir/$output' using 1:2 title 'Writes KB' with lines ls 1"
elif [ $graph = io_wait ]
	then file_pattern="iostat"
	title="IO wait for $date"
	xlabel="Time"
	ylabel="Wait"
	limit=$limit1
    plot_command="plot '$tmpdir/$output' using 1:2 title 'wait' with lines ls 1"
elif [ $graph = mem_used ]
	then file_pattern="mem"
	title="Used Memory for $date"
	xlabel="Time"
	ylabel="Used"
	limit=$limit1
    plot_command="plot '$tmpdir/$output' using 1:2 title 'Memory used (GB)' with lines ls 1"
elif [ $graph = active_conn ]    
	then file_pattern="pg_stat_activity"
	title="Active Connections for $date"
	xlabel="Time"
	ylabel="connections"
	limit=$limit1
    plot_command="plot '$tmpdir/$output' using 1:2 title 'Connection Count' with lines ls 1"         
else 
	echo "not right graph type !!"
	exit 0
fi
}

function _get_files {
_property
echo "Grabbing files from $logdir for date: $date..." 

for files in `/usr/bin/find $logdir/ -type f |grep "$date" |grep $file_pattern`
	do cp $files $tmpdir/
done
echo "Uncopressing.."
gunzip $tmpdir/*.gz
}


function _run_parser {
if [ $graph = "cpu_load" ]
	then $parsedir/cpu_usage.sh 
elif [ $graph = load_avg ]
        then $parsedir/load_avg.sh $tmpdir $tmpdir 
elif [ $graph = io_read ]
	then $parsedir/reads_writes.sh $tmpdir $tmpdir $read_disk $read_column $read_op
elif [ $graph = io_write ]
	then $parsedir/reads_writes.sh $tmpdir $tmpdir $write_disk $write_column $write_op
elif [ $graph = io_wait ]
	then $parsedir/response_wait.sh $tmpdir $tmpdir $disk $res_col $svc_col
elif [ $graph = mem_used ]
	then $parsedir/memory_used.sh
elif [ $graph = active_conn ]
        then $parsedir/connection_count.sh $tmpdir $tmpdir
elif [ $graph = locks ]
        then $parsedir/locks-precooked.sh $tmpdir $tmpdir
else 
	echo "no parser :("
fi
}


_get_files

_run_parser 2>/dev/null

pngfile=$graph-$date.png
gnuplot << EOF
set terminal png size 1200,600 enhanced font "Helvetica,20"
set output "$graphdir/$pngfile"
set title "$title"
set xlabel "$xlabel"
set ylabel "$ylabel"
set xdata time
set timefmt '%H:%M:%S'
set xrange[ "00:00:00":"23:59:59" ]
set yrange [ 0:"$limit" ]
set format x "%H:%M"
set datafile separator ','
#plot "../etc/logo.png" binary filetype=png w rgbimage
set style line 1 lc rgb '#800000' lt 10 lw 0.5 pt 1 pi -1 ps 0.5
set style line 4 lc rgb '#32CD32' lt 10 lw 0.5 pt 1 pi -1 ps 0.5
set style line 5 lc rgb '#006400' lt 10 lw 0.5 pt 1 pi -1 ps 0.5
set style line 2 lc rgb '#808080' lt 10 lw 0.5 pt 1 pi -1 ps 0.5
set style line 3 lc rgb '#00BFFF' lt 10 lw 0.5 pt 1 pi -1 ps 0.5
$plot_command
EOF

echo "Cleaning up temp dir .."
#rm -rf $tmpdir/*
echo $tmpdir
composite -geometry +950+10  $logo $graphdir/$pngfile $graphdir/$pngfile
echo "Your file can be found at $graphdir/$pngfile ... enjoy"