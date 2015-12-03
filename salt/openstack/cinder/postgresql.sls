cinder-db:
  pkg.installed:
    - name: python-psycopg2
    - require_in:
      - postgres_user: cinder-db
      - postgres_database: cinder-db
  postgres_user.present:
    - name: {{ salt['pillar.get']('openstack:cinder:database:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:cinder:database:password', 'sscloud-admin-2357') }}
    - require_in:
      - cmd: cinder
      - postgres_database: cinder-db
  postgres_database.present:
    - name: {{ salt['pillar.get']('openstack:cinder:database:name', 'cinder') }}
    - owner: {{ salt['pillar.get']('openstack:cinder:database:user', 'openstack') }}
    - require_in:
      - cmd: cinder
