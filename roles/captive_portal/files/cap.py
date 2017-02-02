#!/usr/bin/python
import cgi
import os, subprocess

URL_REDIR="http://ideasbox.lan"
#REMOTE_IP="10.10.10.10"

def allow_host(ipaddress):
	"""
	Allow host to bypass ideascube server
	"""
	cmd = "sudo iptables -t nat -I CAPTIVE_PASSLIST 1 -s {ip} -j ACCEPT".format(ip=ipaddress)
	subprocess.check_output(cmd, shell=True)


REMOTE_IP=cgi.escape(os.environ["REMOTE_ADDR"])
allow_host(REMOTE_IP)
print ("Content-type:text/html\r\n\r\n")
print ("""<html><head><meta http-equiv="refresh" content="2; URL='%s'" />Going to ideasbox.lan</head></html>""" % URL_REDIR)

