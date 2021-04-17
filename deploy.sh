#!/bin/sh

SYSTEMPLATES=/usr/share/openstack-tripleo-heat-templates
LOCALTEMPLATES=$PWD/templates

set -ue

deploy_args=(
	-e $SYSTEMPLATES/environments/network-isolation.yaml
	-e $SYSTEMPLATES/environments/network-environment.yaml
	-e $SYSTEMPLATES/environments/deployed-server-environment.yaml

	# Enable ironic
	-e $SYSTEMPLATES/environments/services/ironic.yaml
	-e $SYSTEMPLATES/environments/services/ironic-inspector.yaml

	-e $LOCALTEMPLATES/container-prepare-parameter.yaml
	-e $LOCALTEMPLATES/deploy.yaml
	-e $LOCALTEMPLATES/network-environment-overrides.yaml

	# Enable SSL. This file must set SSLKey, SSLCertificate (and possibly
	# SSLIntermediateCertificate)
	-e $SYSTEMPLATES/environments/ssl/enable-tls.yaml
	-e $SYSTEMPLATES/environments/ssl/tls-endpoints-public-dns.yaml
	-e $LOCALTEMPLATES/ssl.yaml

	-n $LOCALTEMPLATES/network_data.yaml
	-r $LOCALTEMPLATES/roles_data.yaml
)

if ! [ -f templates/container-prepare-parameter.yaml ]; then
	openstack tripleo container image prepare default --local-push-destination \
		--output-env-file templates/container-prepare-parameter.yaml > /dev/null
fi

openstack overcloud deploy \
	--disable-validations --deployed-server \
	--overcloud-ssh-user stack \
	--templates \
	--ntp-server 0.centos.pool.ntp.org \
	"${deploy_args[@]}" \
	"$@"
