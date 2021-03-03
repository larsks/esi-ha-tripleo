GENERATED = \
	container-prepare-parameter.yaml

REQUIRED = \
	undercloud.conf \
	templates/network-data.yaml \
	templates/roles-data.yaml

all: $(GENERATED) $(REQUIRED)

install-undercloud: undercloud.installed

stackrc undercloud-passwords.conf: undercloud.installed

undercloud.installed: undercloud.conf container-prepare-parameter.yaml
	openstack undercloud install
	touch $@

undercloud.conf: /usr/share/python-tripleoclient/undercloud.conf.sample
	cp $< $@

container-prepare-parameter.yaml:
	openstack tripleo container image prepare default \
		--local-push-destination \
		--output-env-file $@ > /dev/null

templates/network-data.yaml: /usr/share/openstack-tripleo-heat-templates/network_data.yaml
	cp $< $@

templates/roles-data.yaml:
	openstack overcloud roles generate -o $@ Controller

generated-templates: templates/roles-data.yaml templates/network-data.yaml
	rm -rf generated-templates
	/usr/share/openstack-tripleo-heat-templates/tools/process-templates.py \
		-p /usr/share/openstack-tripleo-heat-templates \
		-r $(PWD)/templates/roles-data.yaml \
		-n $(PWD)/templates/network-data.yaml \
		-o generated-templates --safe


clean:
	rm -f $(GENERATED)
