include:
  - nginx

openstack-dashboard:
  pkg.installed:
    - pkgs:
      - openstack-dashboard
      - uwsgi
      - uwsgi-plugin-python
  file.managed:
    - name: /etc/openstack-dashboard/local_settings.py
    - source: salt://openstack/horizon/local_settings.py
    - template: jinja
    - require:
      - pkg: openstack-dashboard

openstack-dashboard-ubuntu-theme:
  pkg.purged:
    - require:
      - pkg: openstack-dashboard

horizon-uwsgi:
  file.managed:
    - name: /etc/sscloud/horizon.ini
    - source: salt://openstack/horizon/horizon.ini
    - makedirs: True
    - template: jinja

horizon-upstart:
  file.managed:
    - name: /etc/init/horizon.conf
    - source: salt://openstack/horizon/horizon.conf
    - template: jinja

horizon:
  file.symlink:
    - name: /etc/init.d/horizon
    - target: /lib/init/upstart-job
  service.running:
    - require:
      - pkg: openstack-dashboard-ubuntu-theme
      - file: openstack-dashboard
      - file: horizon-uwsgi
      - file: horizon-upstart
      - file: horizon
