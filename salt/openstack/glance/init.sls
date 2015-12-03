{% if salt['pillar.get']('openstack:glance:database:backend', 'mysql') in ['mysql', 'postgresql'] %}
include:
  - openstack.glance.{{ salt['pillar.get']('openstack:glance:database:backend', 'mysql') }}
{% endif %}

{% for serv in ['api', 'registry'] %}
/etc/glance/glance-{{ serv }}.conf:
  file.managed:
    - source: salt://openstack/glance/glance-{{ serv }}.conf
    - template: jinja
    - makedirs: True
    - require_in:
      - pkg: glance

glance-{{ serv }}:
  service.running:
    - enable: False
    - require:
      - cmd: glance
      - keystone: glance-user
      - keystone: glance-endpoint
{% endfor %}

glance:
  pkg.installed:
    - require_in:
      - cmd: glance
  cmd.run:
    - name: glance-manage db_sync
    - user: glance

glance-tenant:
  keystone.tenant_present:
    - name: {{ salt['pillar.get']('openstack:glance:auth:tenant','service') }}
    - description: 'OpenStack Service'

glance-role:
  keystone.role_present:
    - name: admin

glance-user:
  keystone.user_present:
    - name: {{ salt['pillar.get']('openstack:glance:auth:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:glance:auth:password', salt['pillar.get']('openstack:admin:token','sscloud-admin-2357')) }}
    - email: {{ salt['pillar.get']('openstack:glance:auth:email', 'admin@localhost' ) }}
    - tenant: {{ salt['pillar.get']('openstack:glance:auth:tenant', 'service') }}
    - roles:
        {{ salt['pillar.get']('openstack:glance:auth:tenant', 'service') }}:
          - admin
    - require:
      - keystone: glance-tenant
      - keystone: glance-role

glance-service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: OpenStack Image service

glance-endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: {{ salt['pillar.get']('openstack:glance:endpoint:public', "http://" + salt['pillar.get']('openstack:public:domain', grains["host"]) + ":9292") }}
    - internalurl: {{ salt['pillar.get']('openstack:glance:endpoint:internal', "http://" + grains['host'] + ":9292") }}
    - adminurl: {{ salt['pillar.get']('openstack:glance:endpoint:admin', "http://" + grains['host'] + ":9292") }}
    - region: {{ salt['pillar.get']('openstack:glance:endpoint:region', salt['pillar.get']('openstack:region','regionOne')) }}
    - require:
      - keystone: glance-service
