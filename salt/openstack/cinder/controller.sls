include:
  - openstack.cinder.config
  {% if salt['pillar.get']('openstack:cinder:database:backend', 'mysql') in ['mysql', 'postgresql'] %}
  - openstack.cinder.{{ salt['pillar.get']('openstack:cinder:database:backend', 'mysql') }}
  {% endif %}

cinder:
  pkg.installed:
    - pkgs:
      - cinder-api
      - cinder-scheduler
    - require:
      - file: /etc/cinder/cinder.conf
  cmd.run:
    - name: cinder-manage db sync
    - user: cinder
    - require:
      - pkg: cinder

{% for serv in ['cinder-api', 'cinder-scheduler'] %}
{{ serv }}:
  service.running:
    - enable: False
    - require:
      - cmd: cinder
      - keystone: cinder-user
      - keystone: cinder-endpoint 
      - keystone: cinderv2-endpoint 
{% endfor %}

cinder-tenant:
  keystone.tenant_present:
    - name: {{ salt['pillar.get']('openstack:cinder:auth:tenant','service') }}
    - description: 'OpenStack Service'

cinder-role:
  keystone.role_present:
    - name: admin

cinder-user:
  keystone.user_present:
    - name: {{ salt['pillar.get']('openstack:cinder:auth:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:cinder:auth:password', salt['pillar.get']('openstack:admin:token', 'sscloud-admin-2357')) }}
    - email: {{ salt['pillar.get']('openstack:cinder:auth:email', 'admin@localhost' ) }}
    - tenant: {{ salt['pillar.get']('openstack:cinder:auth:tenant', 'service') }}
    - roles:
        {{ salt['pillar.get']('openstack:cinder:auth:tenant', 'service') }}:
          - admin
    - require:
      - keystone: cinder-tenant
      - keystone: cinder-role

cinder-service:
  keystone.service_present:
    - name: cinder
    - service_type: volume
    - description: OpenStack Block Storage

cinder-endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: {{ salt['pillar.get']('openstack:cinder:endpoint:public', "http://" + salt['pillar.get']('openstack:public:domain', grains["host"]) + ":8776/v2/%(tenant_id)s") }}
    - internalurl: {{ salt['pillar.get']('openstack:cinder:endpoint:internal', "http://" + grains['host'] + ":8776/v2/%(tenant_id)s") }}
    - adminurl: {{ salt['pillar.get']('openstack:cinder:endpoint:admin', "http://" + grains['host'] + ":8776/v2/%(tenant_id)s") }}
    - region: {{ salt['pillar.get']('openstack:cinder:endpoint:region', salt['pillar.get']('openstack:region','regionOne')) }}
    - require:
      - keystone: cinder-service

cinderv2-service:
  keystone.service_present:
    - name: cinderv2
    - service_type: volumev2
    - description: OpenStack Block Storage
    - require:
      - keystone: cinder-service

cinderv2-endpoint:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: {{ salt['pillar.get']('openstack:cinder:endpoint:public', "http://" + salt['pillar.get']('openstack:public:domain', grains["host"]) + ":8776/v2/%(tenant_id)s") }}
    - internalurl: {{ salt['pillar.get']('openstack:cinder:endpoint:internal', "http://" + grains['host'] + ":8776/v2/%(tenant_id)s") }}
    - adminurl: {{ salt['pillar.get']('openstack:cinder:endpoint:admin', "http://" + grains['host'] + ":8776/v2/%(tenant_id)s") }}
    - region: {{ salt['pillar.get']('openstack:cinder:endpoint:region', salt['pillar.get']('openstack:region','regionOne')) }}
    - require:
      - keystone: cinderv2-service
      - keystone: cinder-endpoint
