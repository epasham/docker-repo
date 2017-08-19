#!/usr/bin/env python

import os, sys

def print_usage_and_quit():
	print "Usage: %s <WARNING> <CRITICAL>" % sys.argv[0]
	print "<WARNING> and <CRITICAL> are percentage values of memory used."
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

	mem = {}
	with open('/proc/meminfo') as f:
		for line in f:
			(name, val) = line.split(":")
			mem[name] = val.strip()
	free = mem['MemFree'].replace(" kB", "")
	active = mem['Active(file)'].replace(" kB", "")
	inactive = mem['Inactive(file)'].replace(" kB", "")
	reclaimable = mem['SReclaimable'].replace(" kB", "")
	available = int(free) + int(active) + int(inactive) + int(reclaimable)
	total = float(mem['MemTotal'].replace(" kB", ""))
	mem_usage = 1 - (float(available) / float(total))

	if (mem_usage > critical):
		print "mem_usage: %.2f%% of %dGB!!" % (mem_usage * 100, total / (1024))
		exit(2)
	elif (mem_usage > warning):
		print "mem_usage: %.2f%% of %dGB" % (mem_usage * 100, total / 1024 / 1024)
		exit(1)
	else:
		print "mem_usage: %.2f%% of %dGB" % (mem_usage * 100, total / 1024 / 1024)
		exit(0)