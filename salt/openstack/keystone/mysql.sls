keystone-db:
  pkg.installed:
    - name: python-mysqldb
    - require_in:
      - mysql_user: keystone-db
      - mysql_database: keystone-db
      - mysql_grants: keystone-db
  mysql_user.present:
    - name: {{ salt['pillar.get']('openstack:keystone:database:user', 'openstack') }}
    - host: '%'
    - password: {{ salt['pillar.get']('openstack:keystone:database:password', 'sscloud-admin-2357') }}
  mysql_database.present:
    - name: {{ salt['pillar.get']('openstack:keystone:database:name', 'keystone') }}
  mysql_grants.present:
    - database: {{ salt['pillar.get']('openstack:keystone:database:name', 'keystone') }}.*
    - grant: all privileges
    - user: {{ salt['pillar.get']('openstack:keystone:database:user', 'openstack') }}
    - host: '%'
    - require:
      - mysql_user: keystone-db
      - mysql_database: keystone-db
    - require_in:
      - cmd: keystone
