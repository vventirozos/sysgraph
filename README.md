This is a simple script that will create gnuplot graphs out of any metric.
It's not the smartest thing ever created, actually it is horrible in many ways
but its a result of 1-2 days work. its fast has no dependencies and if you set it up it will 
work.Not sure how much more efford i will put on this but goes well for me in my production systems, 
i am definitely planning to inprove.


To Do : move properties of the graph elsewhere , add many checks , change output.csv to a variable,
         make the plot command more simple


It requires gnuplot, stadard unix utilities and imagemagick if you want to add a custom logo.
The script requires some configuration before its executed , like input / output dir, check the config
for more detail and a brief sentence of what each variable means.
When its good to go then just run :
./sysgraph <date eg: 2014-12-29> <graph name, check help> 

New graphs can be added relatively easy and thats what the rest of the documentation describes.

current implemented graphs are :

cpu_load
load_avg
io_read
io_write
io_wait
mem_used
active_conn (active postgresql connections)
pg_shared_buffers (it doesn't get it from pg_shared_buffers view, so its not very informative)

Other graphs can be easily added but you will need 3 things :

1. A Parser
Parser can be any program or script, it has to have at least 2 variables for input and output dir,
it can have many other variables defined in the configuration file (see bellow)
parsers final file should be called output.csv (to be fixed and defined in the config file).


2. config file
configuration file has options for the parsers and some global variables defined, it can hold
all configuration parameters for the parsers, like :

read_disk="fioa"
read_column="rkB/s"

3. script changes

Adding a new parser needs some editing in the script (sysgraph.sh):

in function _property:

elif [ $graph = io_read ]
        then
        title="io read report for $date"
        xlabel="time"
        ylabel="KB"
        limit="10000"
        file_pattern="iostat"
        plot_command="plot '$tmpdir/output.csv' using 1:2 title 'Reads KB' with lines ls 1"                               

A new block similar to this has to be added for each new graph 
title           = title of the graph
x/ylabel        = title of X or Y axis
limit           = limit that you want to set (usefull for big spikes)
file_pattern    = the pattern of the file that the script to work with
plot_command    = the plot command that will run, "1:2" means plot field 1,2 , "lines ls 1" is the type 
                and style of the graph

A new block similar to the following has to be added in function _run_parser

elif [ $graph = io_read ]
        then $parsedir/reads_writes.sh $tmpdir $tmpdir $read_disk $read_column $read_op

the variables should be defined in configuration file

4. logo
in order to add a logo on the graph you need to have imagemagick and a logo logo's path can be
defined in the configuration file.

