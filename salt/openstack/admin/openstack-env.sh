#!/bin/bash

if groups $username | grep &>/dev/null '\bopenstack\b' ; then

	export OS_IMAGE_API_VERSION=2
	export OS_VOLUME_API_VERSION=2

	if [ "$1" == "admin" ];then

		unset OS_PROJECT_DOMAIN_ID
		unset OS_USER_DOMAIN_ID
		unset OS_PROJECT_NAME
		unset OS_TENANT_NAME
		unset OS_USERNAME
		unset OS_PASSWORD
		unset OS_AUTH_URL

		export OS_TOKEN={{ salt['pillar.get']('openstack:admin:token', 'sscloud-admin-2357') }}
		export OS_URL={{ salt['pillar.get']('openstack:keystone:endpoint:admin', "http://" + salt['pillar.get']('openstack:keystone:host', ['localhost'])[0] + ":35357/v2.0").split('/v2.0')[0] }}/v3

		echo "You have super privileges for OpenStack now."

	else

		unset OS_TOKEN
		unset OS_ENDPOINT

		export OS_PROJECT_DOMAIN_ID=default
		export OS_USER_DOMAIN_ID=default
		export OS_PROJECT_NAME={{ salt['pillar.get']('openstack:admin:project', 'admin') }}
		export OS_TENANT_NAME={{ salt['pillar.get']('openstack:admin:project', 'admin') }}
		export OS_USERNAME={{ salt['pillar.get']('openstack:admin:user', 'sscloud') }}
		export OS_PASSWORD={{ salt['pillar.get']('openstack:admin:password', 'sscloud-admin-2357') }}
		export OS_AUTH_URL={{ salt['pillar.get']('openstack:keystone:endpoint:endpoint', "http://" + salt['pillar.get']('openstack:keystone:host', ['localhost'])[0] + ":35357/v2.0").split('/v2.0')[0] }}/v3

		echo "You have enable Admin account."

	fi

fi
