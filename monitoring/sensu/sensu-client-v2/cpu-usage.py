#!/usr/bin/env python

import os, sys, time

# cpu usage methods from http://stackoverflow.com/a/1296768
def getTimeList():
    """
    Fetches a list of time units the cpu has spent in various modes
    Detailed explanation at http://www.linuxhowtos.org/System/procstat.htm
    """
    cpuStats = file("/proc/stat", "r").readline()
    columns = cpuStats.replace("cpu", "").split(" ")
    return map(int, filter(None, columns))

def deltaTime(interval):
    """
    Returns the difference of the cpu statistics returned by getTimeList
    that occurred in the given time delta
    """
    timeList1 = getTimeList()
    time.sleep(interval)
    timeList2 = getTimeList()
    return [(t2-t1) for t1, t2 in zip(timeList1, timeList2)]

def cpu_load():
    """
    Returns the cpu load as a value from the interval [0.0, 0.1]
    """
    dt = list(deltaTime(0.1))
    idle_time = float(dt[3])
    total_time = sum(dt)
    load = 1-(idle_time/total_time)
    return load

def print_usage_and_quit():
    print "Usage: %s <WARNING> <CRITICAL>" % sys.argv[0]
    print "<WARNING> and <CRITICAL> are percentage values of CPU usage."
    print "E.g.: %s 0.8 0.95" % sys.argv[0]
    exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print "Missing arguments."
        print_usage_and_quit()

    try:
        warning = float(sys.argv[1])
        critical = float(sys.argv[2])
    except ValueError:
        print "Failed to interpret arguments."
        print_usage_and_quit()

    cpu_usage = cpu_load()
    if (cpu_usage > critical):
        print "cpu_usage: %.2f%%!!" % (cpu_usage * 100)
        exit(2)
    elif(cpu_usage > warning):
        print "cpu_usage: %.2f%%" % (cpu_usage * 100)
        exit(1)
    else:
        print "cpu_usage: %.2f%%" % (cpu_usage * 100)
        exit(0)