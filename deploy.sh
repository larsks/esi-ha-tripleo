#!/bin/sh

SYSTEMPLATES=/usr/share/openstack-tripleo-heat-templates
LOCALTEMPLATES=$PWD/templates

deploy_args=(
	-e $SYSTEMPLATES/environments/network-isolation.yaml
	-e $SYSTEMPLATES/environments/network-environment.yaml
	-e $SYSTEMPLATES/environments/deployed-server-environment.yaml
	-e $PWD/container-prepare-parameter.yaml
	-e $LOCALTEMPLATES/deploy.yaml
	-n $LOCALTEMPLATES/network-data.yaml
)

openstack overcloud deploy \
	--disable-validations --deployed-server \
	--overcloud-ssh-user stack \
	--templates \
	--ntp-server 0.centos.pool.ntp.org \
	"${deploy_args[@]}" \
	"$@"
