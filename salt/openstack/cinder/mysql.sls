cinder-db:
  pkg.installed:
    - name: python-mysqldb
    - require_in:
      - mysql_user: cinder-db
      - mysql_database: cinder-db
      - mysql_grants: cinder-db
  mysql_user.present:
    - name: {{ salt['pillar.get']('openstack:cinder:database:user', 'openstack') }}
    - host: '%'
    - password: {{ salt['pillar.get']('openstack:cinder:database:password', 'sscloud-admin-2357') }}
  mysql_database.present:
    - name: {{ salt['pillar.get']('openstack:cinder:database:name', 'cinder') }}
  mysql_grants.present:
    - database: {{ salt['pillar.get']('openstack:cinder:database:name', 'cinder') }}.*
    - grant: all privileges
    - user: {{ salt['pillar.get']('openstack:cinder:database:user', 'openstack') }}
    - host: '%'
    - require:
      - mysql_user: cinder-db
      - mysql_database: cinder-db
    - require_in:
      - cmd: cinder
