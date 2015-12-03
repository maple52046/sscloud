{% if salt['pillar.get']('openstack:nova:database:backend', 'mysql') in ['mysql', 'postgresql'] %}
include:
  - openstack.nova.{{ salt['pillar.get']('openstack:nova:database:backend', 'mysql')  }}
{% endif %}

nova:
  pkg.installed:
    - pkgs:
      - nova-api
      - nova-cert
      - nova-conductor
      - nova-consoleauth
      - nova-scheduler
      - python-novaclient
    - require:
      - file: nova
  file.managed:
    - name: /etc/nova/nova.conf
    - source: salt://openstack/nova/nova.conf
    - template: jinja
    - makedirs: True
  cmd.run:
    - name: nova-manage db sync
    - user: nova
    - require:
      - pkg: nova

{% for serv in ['api', 'cert', 'conductor', 'consoleauth', 'scheduler'] %}
nova-{{ serv }}:
  service.running:
    - enable: False
    - require:
      - cmd: nova
      - keystone: nova-user
      - keystone: nova-endpoint
      #{% if salt['pillar.get']('openstack:nova:rpc:backend', 'rabbit') == 'rabbit' %}
      #- rabbitmq_user: nova-rpc-user
      #{% endif %}
{% endfor %}


nova-tenant:
  keystone.tenant_present:
    - name: {{ salt['pillar.get']('openstack:nova:auth:tenant','service') }}
    - description: 'OpenStack Service'

nova-role:
  keystone.role_present:
    - name: admin

nova-user:
  keystone.user_present:
    - name: {{ salt['pillar.get']('openstack:nova:auth:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:nova:auth:password', salt['pillar.get']('openstack:admin:token', 'sscloud-admin-2357')) }}
    - email: {{ salt['pillar.get']('openstack:nova:auth:email', 'admin@localhost' ) }}
    - tenant: {{ salt['pillar.get']('openstack:nova:auth:tenant', 'service') }}
    - roles:
        {{ salt['pillar.get']('openstack:nova:auth:tenant', 'service') }}:
          - admin
    - require:
      - keystone: nova-tenant
      - keystone: nova-role

nova-service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: OpenStack Compute service

nova-endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: {{ salt['pillar.get']('openstack:nova:endpoint:public', "http://" + salt['pillar.get']('openstack:public:domain', grains["host"]) + ":8774/v2/%(tenant_id)s") }}
    - internalurl: {{ salt['pillar.get']('openstack:nova:endpoint:internal', "http://" + grains['host'] + ":8774/v2/%(tenant_id)s") }}
    - adminurl: {{ salt['pillar.get']('openstack:nova:endpoint:admin', "http://" + grains['host'] + ":8774/v2/%(tenant_id)s") }}
    - region: {{ salt['pillar.get']('openstack:nova:endpoint:region', salt['pillar.get']('openstack:region','regionOne')) }}
    - require:
      - keystone: nova-service
