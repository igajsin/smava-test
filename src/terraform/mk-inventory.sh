#!/bin/sh

NAME=$1
IP=$2
INVENTORY=../playbooks/inventory

sed -r "s/$NAME.*(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b/$NAME ansible_host=$IP/" -i $INVENTORY
