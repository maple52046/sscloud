glance-db:
  pkg.installed:
    - name: python-psycopg2
    - require_in:
      - postgres_user: glance-db
      - postgres_database: glance-db
  postgres_user.present:
    - name: {{ salt['pillar.get']('openstack:glance:database:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:glance:database:password', 'sscloud-admin-2357') }}
    - require_in:
      - cmd: glance
      - postgres_database: glance-db
  postgres_database.present:
    - name: {{ salt['pillar.get']('openstack:glance:database:host', salt['pillar.get']('mysql:host', ['localhost'])[0]) }}
    - owner: {{ salt['pillar.get']('openstack:glance:database:user', 'openstack') }}
    - require_in:
      - cmd: glance
