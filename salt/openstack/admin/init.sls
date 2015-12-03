include:
  - openstack.admin.registry

openstack-client:
  pkg.installed:
    - pkgs:
      - python-openstackclient
      - python-pip
      - python-dev
  group.present:
    - system: True
    - members:
      - root
  file.managed:
    - name: /etc/profile.d/openstack-env.sh
    - source: salt://openstack/admin/openstack-env.sh
    - template: jinja
  cmd.run:
    - name: pip install msgpack-python==0.4.0
    - require:
      - pkg: openstack-client
    - order: 0

/root/openrc:
  file.symlink:
    - target: /etc/profile.d/openstack-env.sh
    - require:
      - file: openstack-client

admin-tenant:
  keystone.tenant_present:
    - name: {{ salt['pillar.get']('openstack:admin:tenant','admin') }}
    - description: 'OpenStack Administrator'

admin-role:
  keystone.role_present:
    - name: admin

admin-user:
  keystone.user_present:
    - name: {{ salt['pillar.get']('openstack:admin:user', 'admin') }}
    - password: {{ salt['pillar.get']('openstack:admin:password', 'sscloud-admin-2357') }}
    - email: {{ salt['pillar.get']('openstack:admin:email', 'admin@localhost' ) }}
    - tenant: {{ salt['pillar.get']('openstack:admin:tenant', 'admin') }}
    - roles:
        {{ salt['pillar.get']('openstack:admin:tenant', 'admin') }}:
          - admin
    - require:
      - keystone: admin-tenant
      - keystone: admin-role
