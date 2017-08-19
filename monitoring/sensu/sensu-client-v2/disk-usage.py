#!/usr/bin/env python

import os, sys

def print_usage_and_quit():
	print "Usage: %s <WARNING> <CRITICAL>" % sys.argv[0]
	print "<WARNING> and <CRITICAL> are percentage values of disk space left."
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

	disk = os.statvfs("/")
	free = disk.f_bavail * disk.f_frsize
	total = disk.f_blocks * disk.f_frsize
	used = (disk.f_blocks - disk.f_bfree) * disk.f_frsize
	percent = used / float(total)

	if (percent > critical):
		print "disk_usage: %.2f%% of %dGB!!" % (percent * 100, total / 1024 / 1024 / 1024)
		exit(2)
	elif (percent > warning):
		print "disk_usage: %.2f%% of %dGB" % (percent * 100, total / 1024 / 1024 / 1024)
		exit(1)
	else:
		print "disk_usage: %.2f%% of %dGB" % (percent * 100, total / 1024 / 1024 / 1024)
		exit(0)
