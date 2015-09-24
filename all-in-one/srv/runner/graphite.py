# -*- coding: utf-8 -*-

from __future__ import absolute_import

import salt.pillar

# Import salt libs
import salt.utils.error
        
def send(minion_id, data, host, port):
    """
    a method to send metric to graphite
    """
    import socket
    timeout_in_seconds = 2
    _socket = socket.socket()
    _socket.settimeout(timeout_in_seconds)
    addr=(host, port)
    messages = _generate_messages(minion_id, data)
    if len(messages)==0:
        return
    try:
        _socket.connect(addr)
    except socket.timeout:
        salt.utils.error.raise_error(name="graphite.send", message="Took over %d second(s) to connect to %s" % (timeout_in_seconds, addr))
    except socket.gaierror:
        salt.utils.error.raise_error(name="graphite.send", message="No address associated with hostname %s" % addr)
    except Exception as error:
        salt.utils.error.raise_error(name="graphite.send", message="unknown exception while connecting to %s - %s" % (addr, error))

    try:
        _socket.sendall('\n'.join(messages)+'\n')

    # Capture missing socket.
    except socket.gaierror as error:
        salt.utils.error.raise_error(name="graphite.send", message="Failed to send data to %s, with error: %s" % (addr, error))

    # Capture socket closure before send.
    except socket.error as error:
        salt.utils.error.raise_error(name="graphite.send", message="Socket closed before able to send data to %s, with error: %s" % (addr, error))

    except Exception as error:
        salt.utils.error.raise_error(name="graphite.send", message="Unknown error while trying to send data down socket to %s, with error: %s" % (addr, error))

    try:
        _socket.close()

    # If its currently a socket, set it to None
    except AttributeError:
        pass
    except Exception:
        pass

def _generate_messages(minion_id, data):
    messages=[]
    if data['tag']=='load':
        messages.append("%s.%s.1m %s %d" % (minion_id, data['tag'], data['1m'], data['timestamp'] ))
        messages.append("%s.%s.5m %s %d" % (minion_id, data['tag'], data['5m'], data['timestamp'] ))
        messages.append("%s.%s.15m %s %d" % (minion_id, data['tag'], data['15m'], data['timestamp'] ))
    elif data['tag']=='memory':
        messages.append("%s.%s.total %s %d" % (minion_id, data['tag'], data['total'], data['timestamp'] ))
        messages.append("%s.%s.free %s %d" % (minion_id, data['tag'], data['free'], data['timestamp'] ))
        messages.append("%s.%s.used %s %d" % (minion_id, data['tag'], data['used'], data['timestamp'] ))
        messages.append("%s.%s.buffered %s %d" % (minion_id, data['tag'], data['buffered'], data['timestamp'] ))
        messages.append("%s.%s.cached %s %d" % (minion_id, data['tag'], data['cached'], data['timestamp'] ))
        if 'slab_total' in data:
            messages.append("%s.%s.cached %s %d" % (minion_id, data['tag'], data['slab_total'], data['timestamp'] ))
        if 'slab_reclaimable' in data:
            messages.append("%s.%s.cached %s %d" % (minion_id, data['tag'], data['slab_reclaimable'], data['timestamp'] ))
        if 'slab_unreclaimable' in data:
            messages.append("%s.%s.cached %s %d" % (minion_id, data['tag'], data['slab_unreclaimable'], data['timestamp'] ))
    elif data['tag']=='cpu':
        for cpu_no, stat in data['cpu'].iteritems():
            messages.append("%s.%s.%s.idle %s %d" % (minion_id, data['tag'], cpu_no, stat['idle'], data['timestamp'] ))
            messages.append("%s.%s.%s.user %s %d" % (minion_id, data['tag'], cpu_no, stat['user'], data['timestamp'] ))
            messages.append("%s.%s.%s.nice %s %d" % (minion_id, data['tag'], cpu_no, stat['nice'], data['timestamp'] ))
            messages.append("%s.%s.%s.system %s %d" % (minion_id, data['tag'], cpu_no, stat['system'], data['timestamp'] ))
            if 'wait' in stat:
                messages.append("%s.%s.%s.wait %s %d" % (minion_id, data['tag'], cpu_no, stat['wait'], data['timestamp'] ))
            if 'interrupt' in stat:
                messages.append("%s.%s.%s.interrupt %s %d" % (minion_id, data['tag'], cpu_no, stat['interrupt'], data['timestamp'] ))
            if 'softirq' in stat:
                messages.append("%s.%s.%s.softirq %s %d" % (minion_id, data['tag'], cpu_no, stat['softirq'], data['timestamp'] ))
            if 'steal' in stat:
                messages.append("%s.%s.%s.steal %s %d" % (minion_id, data['tag'], cpu_no, stat['steal'], data['timestamp'] ))
    elif data['tag']=='interface':
        for interface, stat in data['interface'].iteritems():
            for direction in stat.keys():
                for field in stat[direction].keys():
                    messages.append("%s.%s.%s.%s.%s %s %d" % (minion_id, data['tag'], interface, field, direction, stat[direction][field], data['timestamp'] ))
    elif data['tag']=='disk':
        for disk, stat in data['disk'].iteritems():
            for direction in ['read', 'write']:
                for field in stat[direction].keys():
                    messages.append("%s.%s.%s.%s.%s %s %d" % (minion_id, data['tag'], disk, field, direction, stat[direction][field], data['timestamp'] ))
    return messages

def cleanup(minion_id, whisper_path):
    """
    a method to clean up metric data in whisper
    """
    import shutil
    import os
    try:
        shutil.rmtree(whisper_path+os.linesep+minion_id)
    except Exception as error:
        salt.utils.error.raise_error(name="graphite.cleanup", message="unable to cleanup data for worker node %s: %s" % (minion_id, error))