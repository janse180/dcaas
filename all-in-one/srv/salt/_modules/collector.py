# -*- coding: utf-8 -*-

import time
import re

def _readfile(filename):
    with open(filename) as f:
        content = f.readlines()
    return content

def collect_load_avg():
    lines=_readfile("/proc/loadavg")
    variables=lines[0].split(" ")
    return {"tag": "load", "timestamp": int(time.time()), "1m": variables[0], "5m": variables[1], "15m": variables[2]}

def collect_cpu_stat():
    lines=_readfile("/proc/stat")
    data={"tag": "cpu", "timestamp": int(time.time()), "cpu": {}}
    for line in lines:
        if line.startswith('cpu'):
            variables = line.split()
            if len(variables[0])==3:
                continue
            cpu_no=variables[0][3:]
            data['cpu'][cpu_no] = {}
            data['cpu'][cpu_no]['user'] = int(variables[1])
            data['cpu'][cpu_no]['nice'] = int(variables[2])
            data['cpu'][cpu_no]['system'] = int(variables[3])
            data['cpu'][cpu_no]['idle'] = int(variables[4])
            if len(variables)>=8:
                data['cpu'][cpu_no]['wait'] = int(variables[5])
                data['cpu'][cpu_no]['interrupt'] = int(variables[6])
                data['cpu'][cpu_no]['softirq'] = int(variables[7])
                if len(variables)>=9:
                    data['cpu'][cpu_no]['steal'] = int(variables[8])
    return data

def collect_mem_info():
    lines=_readfile("/proc/meminfo")
    data={"tag": "memory", "timestamp": int(time.time())}
    for line in lines:
        variables = line.split()
        if variables[0].startswith('MemTotal'):
            data['total'] = int(variables[1])
        elif variables[0].startswith('MemFree'):
            data['free'] = int(variables[1])
        elif variables[0].startswith('Buffers'):
            data['buffered'] = int(variables[1])
        elif variables[0].startswith('Cached'):
            data['cached'] = int(variables[1])
        elif variables[0].startswith('Slab'):
            data['slab_total'] = int(variables[1])
        elif variables[0].startswith('SReclaimable'):
            data['slab_reclaimable'] = int(variables[1])
        elif variables[0].startswith('SUnreclaim'):
            data['slab_unreclaimable'] = int(variables[1])
    data['used'] = data['total'] - (data['free'] + data['buffered'] + data['cached'] + data['slab_total'])
    return data

fields = {
    "if_octets" : 0,
    "if_packets" : 1,
    "if_errors" : 2,
    "if_dropped" : 3
}

directions = {
    "rx" : 2,
    "tx" : 10
}

def collect_net_dev():
    lines=_readfile("/proc/net/dev")
    pattern = re.compile("[ :]+")
    data={"tag": "interface", "timestamp": int(time.time()), "interface": {}}
    for line in lines:
        if ":" in line:
            variables = pattern.split(line)
            interface = variables[1]
            if interface=="lo":
                continue
            data['interface'][interface] = {}
            for direction in directions:
                data['interface'][interface][direction] = {}
                for field in fields:
                    data['interface'][interface][direction][field] = int(variables[directions[direction] + fields[field]])
    return data

disk_fields = {
    "disk_ops" : 0,
    "disk_merged" : 1,
    "disk_octets" : 2,
    "disk_time" : 3
}
disk_directions = {
    "read" : 4,
    "write" : 8
} 
def collect_disk_stat():
    lines=_readfile("/proc/diskstats")
    pattern = re.compile("[ :]+")
    data={"tag": "disk", "timestamp": int(time.time()), "disk": {}}
    for line in lines:
        variables = pattern.split(line)
        disk_name=variables[3]
        if 'ram' in disk_name or 'loop' in disk_name or 'dm' in disk_name:
            continue
        data['disk'][disk_name] = {}
        for direction in disk_directions:
            data['disk'][disk_name][direction] = {}
            for field in disk_fields:
                data['disk'][disk_name][direction][field] = int(variables[disk_directions[direction] + disk_fields[field]])
        data['disk'][disk_name]['in_progress']=variables[12]
        data['disk'][disk_name]['io_time']=variables[13]
        data['disk'][disk_name]['weighted_time']=variables[14]
    return data
    