glance-db:
  pkg.installed:
    - name: python-mysqldb
    - require_in:
      - mysql_user: glance-db
      - mysql_database: glance-db
      - mysql_grants: glance-db
  mysql_user.present:
    - name: {{ salt['pillar.get']('openstack:glance:database:user', 'openstack') }}
    - host: '%'
    - password: {{ salt['pillar.get']('openstack:glance:database:password', 'sscloud-admin-2357') }}
  mysql_database.present:
    - name: {{ salt['pillar.get']('openstack:glance:database:name', 'glance') }}
  mysql_grants.present:
    - database: {{ salt['pillar.get']('openstack:glance:database:name', 'glance') }}.*
    - grant: all privileges
    - user: {{ salt['pillar.get']('openstack:glance:database:user', 'openstack') }}
    - host: '%'
    - require:
      - mysql_user: glance-db
      - mysql_database: glance-db
    - require_in:
      - cmd: glance
