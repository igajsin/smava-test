#!/bin/sh

IP=$1
CFG=../playbooks/ssh.cfg

sed -i -e "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$IP/g" $CFG
