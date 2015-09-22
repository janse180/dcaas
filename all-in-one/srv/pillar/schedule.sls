schedule:
  collect_load:
    function: collector.collect_load_avg
    seconds: 10
    returner: zeromq
  collect_cpu:
    function: collector.collect_cpu_stat
    seconds: 10
    returner: zeromq
  collect_memory:
    function: collector.collect_mem_info
    seconds: 10
    returner: zeromq
  collect_interface:
    function: collector.collect_net_dev
    seconds: 10
    returner: zeromq
  collect_disk:
    function: collector.collect_disk_stat
    seconds: 10
    returner: zeromq
    