nova-db:
  pkg.installed:
    - name: python-mysqldb
    - require_in:
      - mysql_user: nova-db
      - mysql_database: nova-db
      - mysql_grants: nova-db
  mysql_user.present:
    - name: {{ salt['pillar.get']('openstack:nova:database:user', 'openstack') }}
    - host: '%'
    - password: {{ salt['pillar.get']('openstack:nova:database:password', 'sscloud-admin-2357') }}
  mysql_database.present:
    - name: {{ salt['pillar.get']('openstack:nova:database:name', 'nova') }}
  mysql_grants.present:
    - database: {{ salt['pillar.get']('openstack:nova:database:name', 'nova') }}.*
    - grant: all privileges
    - user: {{ salt['pillar.get']('openstack:nova:database:user', 'openstack') }}
    - host: '%'
    - require:
      - mysql_user: nova-db
      - mysql_database: nova-db
    - require_in:
      - cmd: nova
