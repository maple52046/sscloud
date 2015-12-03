base:
  '*':
    - openstack.cloudrepo
    - system.user
    {% if grains['host'] == salt['pillar.get']('openstack:controller', ['localhost']) %}
    - sscloud.generic.controller
      {% if salt['pillar.get']('openstack:computes', 'other') == 'all' %}
    - sscloud.generic.compute
      {% endif %}
    {% else %}
    - sscloud.generic.compute
    {% endif %}
