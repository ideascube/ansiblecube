#!/bin/bash

ansible_version=`pip freeze | grep ansible= | cut -d "=" -f3`

if [ "$ansible_version" != "2.2.0.0" ]
then
	pip install -U ansible==2.2.0.0
fi