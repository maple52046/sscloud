include:
  - openstack.neutron.ml2
  - openstack.neutron.ovsagent
{% if salt['pillar.get']('openstack:neutron:database:backend', 'mysql') in ['mysql','postgresql'] %}
  - openstack.neutron.{{ salt['pillar.get']('openstack:neutron:database:backend', 'mysql') }}
{% endif %}

neutron-server:
  pkg.installed:
    - require:
      - file: neutron-server
  file.managed:
    - name: /etc/neutron/neutron.conf
    - source: salt://openstack/neutron/neutron.conf
    - template: jinja
    - makedirs: True
  service.running:
    - enable: False
    - require:
      - cmd: neutron-server
  cmd.run:
    - name: neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head
    - user: neutron
    - require:
      - pkg: neutron-server
      - pkg: neutron-plugin-ml2

neutron-tenant:
  keystone.tenant_present:
    - name: {{ salt['pillar.get']('openstack:neutron:auth:tenant','service') }}
    - description: 'OpenStack Service'

neutron-role:
  keystone.role_present:
    - name: admin

neutron-user:
  keystone.user_present:
    - name: {{ salt['pillar.get']('openstack:neutron:auth:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:neutron:auth:password', salt['pillar.get']('openstack:admin:token', 'sscloud-admin-2357')) }}
    - email: {{ salt['pillar.get']('openstack:neutron:auth:email', 'admin@localhost' ) }}
    - tenant: {{ salt['pillar.get']('openstack:neutron:auth:tenant', 'service') }}
    - roles:
        {{ salt['pillar.get']('openstack:neutron:auth:tenant', 'service') }}:
          - admin
    - require:
      - keystone: neutron-tenant
      - keystone: neutron-role

neutron-service:
  keystone.service_present:
    - name: neutron
    - service_type: network
    - description: OpenStack Networking

neutron-endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: {{ salt['pillar.get']('openstack:neutron:endpoint:public', "http://" + salt['pillar.get']('openstack:public:domain', grains["host"]) + ":9696") }}
    - internalurl: {{ salt['pillar.get']('openstack:neutron:endpoint:internal', "http://" + grains['host'] + ":9696") }}
    - adminurl: {{ salt['pillar.get']('openstack:neutron:endpoint:admin', "http://" + grains['host'] + ":9696") }}
    - region: {{ salt['pillar.get']('openstack:neutron:endpoint:region', salt['pillar.get']('openstack:region','regionOne')) }}
    - require:
      - keystone: neutron-service

neutron-dhcp-agent:
  pkg.installed:
    - require:
      - file: neutron-dhcp-agent
  file.managed:
    - name: /etc/neutron/dhcp_agent.ini
    - source: salt://openstack/neutron/dhcp_agent.ini
    - template: jinja
    - makedirs: True
  service.running:
    - enable: False
    - require:
      - file: neutron-dhcp-agent
      - pkg: neutron-dhcp-agent
      - service: neutron-plugin-openvswitch-agent

/etc/neutron/dnsmasq.conf:
  file.managed:
    - source: salt://openstack/neutron/dnsmasq.conf
    - require_in:
      - service: neutron-dhcp-agent
