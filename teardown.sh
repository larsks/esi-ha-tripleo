#!/bin/sh

openstack stack delete -y --wait overcloud
openstack overcloud plan delete overcloud
