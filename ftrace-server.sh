#!/bin/bash

DEBUG_FS=/sys/kernel/debug/tracing/

INIT=1
if [ "$INIT" = "1" ]; then
    echo 0 > $DEBUG_FS/tracing_on
    echo function_graph > $DEBUG_FS/current_tracer
    echo 1 > $DEBUG_FS/max_graph_depth
    echo funcgraph-abstime > $DEBUG_FS/trace_options
    echo x86-tsc > $DEBUG_FS/trace_clock
    echo funcgraph-proc > $DEBUG_FS/trace_options
    echo > set_graph_notrace
    echo do_page_fault syscall_trace_enter syscall_trace_leave > set_graph_notrace
fi

echo > $DEBUG_FS/trace
echo > $DEBUG_FS/set_ftrace_pid
echo $$ > $DEBUG_FS/set_ftrace_pid

echo 1 > $DEBUG_FS/tracing_on
# TODO: when starting server using exec, script/killserver will kill this script and leave tracing_on = 1
#exec $*
$*
echo 0 > $DEBUG_FS/tracing_on
