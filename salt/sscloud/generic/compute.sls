{% if grains['host'] in salt['pillar.get']('openstack:compute', ['localhost']) %}
include:
  - openstack.cloudrepo
  - openstack.nova.compute
  - openstack.neutron.compute
{% endif %}
