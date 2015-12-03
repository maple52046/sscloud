neutron-db:
  pkg.installed:
    - name: python-mysqldb
    - require_in:
      - mysql_user: neutron-db
      - mysql_database: neutron-db
      - mysql_grants: neutron-db
  mysql_user.present:
    - name: {{ salt['pillar.get']('openstack:neutron:database:user', 'openstack') }}
    - host: '%'
    - password: {{ salt['pillar.get']('openstack:neutron:database:password', 'sscloud-admin-2357') }}
  mysql_database.present:
    - name: {{ salt['pillar.get']('openstack:neutron:database:name', 'neutron') }}
  mysql_grants.present:
    - database: {{ salt['pillar.get']('openstack:neutron:database:name', 'neutron') }}.*
    - grant: all privileges
    - user: {{ salt['pillar.get']('openstack:neutron:database:user', 'openstack') }}
    - host: '%'
    - require:
      - mysql_user: neutron-db
      - mysql_database: neutron-db
    - require_in:
      - service: neutron-server
