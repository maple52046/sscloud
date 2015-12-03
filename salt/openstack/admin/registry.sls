registry-keystone-service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: OpenStack Identity

registry-keystone-endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: {{ salt['pillar.get']('openstack:keystone:endpoint:public', 'http://' + salt['pillar.get']('openstack:public:doamin', grains['host']) + ":5000/v2.0") }}
    - internalurl: {{ salt['pillar.get']('openstack:keystone:endpoint:internal', "http://" + grains['host'] + ":5000/v2.0") }}
    - adminurl: {{ salt['pillar.get']('openstack:keystone:endpoint:admin', "http://" + grains['host'] + ":35357/v2.0") }}
    - region: {{ salt['pillar.get']('openstack:keystone:endpoint:region', salt['pillar.get']('openstack:region','regionOne')) }}
    - require:
      - keystone: registry-keystone-service
