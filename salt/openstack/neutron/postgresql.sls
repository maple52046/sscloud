neutron-db:
  pkg.installed:
    - name: python-psycopg2
    - require_in:
      - postgres_user: neutron-db
      - postgres_database: neutron-db
  postgres_user.present:
    - name: {{ salt['pillar.get']('openstack:neutron:database:user', 'openstack') }}
    - password: {{ salt['pillar.get']('openstack:neutron:database:password', 'sscloud-admin-2357') }}
    - require_in:
      - postgres_database: neutron-db
  postgres_database.present:
    - name: {{ salt['pillar.get']('openstack:neutron:database:name', 'neutron') }}
    - owner: {{ salt['pillar.get']('openstack:neutron:database:user', 'openstack') }}
    - require_in:
      - service: neutron-server
