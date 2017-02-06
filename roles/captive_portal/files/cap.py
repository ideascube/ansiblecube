#!/usr/bin/python
import cgi
import os, subprocess

URL_REDIR="http://ideasbox.lan"

def allow_host(ipaddress):
	"""
	Allow host ip to bypass ideascube server
	"""
	cmd = "sudo iptables -t nat -I CAPTIVE_PASSLIST 1 -s {ip} -j ACCEPT".format(ip=ipaddress)
	subprocess.check_output(cmd, shell=True)


REMOTE_IP=cgi.escape(os.environ["REMOTE_ADDR"])
allow_host(REMOTE_IP)

## Send HTML redirect to forward user to ideasbox.lan/koombook.lan

print ("Content-type:text/html\r\n\r\n")
print ("""<html><head><meta http-equiv="refresh" content="2; URL='%s'" />Going to %s</head></html>""" % (URL_REDIR,URL_REDIR))

