#!/bin/bash

ansible_version=`pip freeze | grep ansible=`

if [ "${ansible_version:9:3}" != "2.2" ]
then
	pip install -U ansible==2.2.0.0
fi