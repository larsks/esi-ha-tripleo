#!/bin/sh

SYSTEMPLATES=/usr/share/openstack-tripleo-heat-templates
LOCALTEMPLATES=$PWD/templates

set -ue

deploy_args=(
	-e $SYSTEMPLATES/environments/network-isolation.yaml
	-e $SYSTEMPLATES/environments/network-environment.yaml
	-e $SYSTEMPLATES/environments/deployed-server-environment.yaml
	-e $PWD/container-prepare-parameter.yaml
	-e $LOCALTEMPLATES/deploy.yaml
	-e $LOCALTEMPLATES/network-environment-overrides.yaml
	-n $LOCALTEMPLATES/network_data.yaml
	-r $LOCALTEMPLATES/roles_data.yaml
)

if ! [ -f container-prepare-parameter.yaml ]; then
	openstack tripleo container image prepare default --local-push-destination --output-env-file container-prepare-parameter.yaml
fi

openstack overcloud deploy \
	--disable-validations --deployed-server \
	--overcloud-ssh-user stack \
	--templates \
	--ntp-server 0.centos.pool.ntp.org \
	"${deploy_args[@]}" \
	"$@"
