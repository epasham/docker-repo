#!/usr/bin/env python

import os, sys

def print_usage_and_quit():
	print "Usage: %s <WARNING> <CRITICAL>" % sys.argv[0]
	print "<WARNING> and <CRITICAL> are percentage values of file handles left."
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

	file_nr = file('/proc/sys/fs/file-nr').read().split()
	handles = file_nr[0]
	total = int(file_nr[2])
	percent = float(handles) / float(total)

	if (percent > critical):
		print "file_handles_used: %.2f%% of %d!!" % (percent * 100, total)
		exit(2)
	elif (percent > warning):
		print "file_handles_used: %.2f%% of %d" % (percent * 100, total)
		exit(1)
	else:
		print "file_handles_used: %.2f%% of %d" % (percent * 100, total)
		exit(0)