nova-db:
  pkg.installed:
    - name: python-psycopg2
    - require_in:
      - postgres_user: nova-db
      - postgres_database: nova-db
  postgres_user.present:
    - name: {{ salt['pillar.get']('openstack:nova:database:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:nova:database:password', 'sscloud-admin-2357') }}
    - require_in:
      - cmd: nova
      - postgres_database: nova-db
  postgres_database.present:
    - name: {{ salt['pillar.get']('openstack:nova:database:name', 'nova') }}
    - owner: {{ salt['pillar.get']('openstack:nova:database:user', 'openstack') }}
    - require_in:
      - cmd: nova
