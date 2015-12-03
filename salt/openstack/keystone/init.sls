include:
  - openstack.keystone.mysql

{% for target in ['main', 'admin'] %}
keystone-cgi-{{ target }}:
  file.managed:
    - name: /var/www/cgi-bin/keystone/{{ target }}
    - source: salt://openstack/keystone/cgi-bin
    - user: keystone
    - group: keystone
    - makedirs: True
    - mode: 0755
{% endfor %}

keystone:
  pkg.installed:
    - pkgs:
      - keystone
      - memcached
      - python-memcache
      - apache2
      - libapache2-mod-wsgi
  file.managed:
    - name: /etc/keystone/keystone.conf
    - source: salt://openstack/keystone/keystone.conf
    - template: jinja
    - makedirs: True
    - require:
      - pkg: keystone
  cmd.run:
    - name: keystone-manage db_sync
    - user: keystone
    - require:
      - file: keystone
  service.dead:
    - enable: False
    - require:
      - pkg: keystone

/etc/apache2/sites-available/keystone.conf:
  file.managed:
    - source: salt://openstack/keystone/apache.conf
    - makedirs: True
    - require:
      - pkg: keystone

disable-apache-default-vhost:
  file.absent:
    - name: /etc/apache2/sites-enabled/000-default.conf
    - require:
      - pkg: keystone

disable-apache-default-port:
  file.managed:
    - name: /etc/apache2/ports.conf
    - content:
        # Modify by SSCloud auto deployment
        # vim: syntax=apache ts=4 sw=4 sts=4 sr noet
    - require:
      - pkg: keystone

wsgi:
  apache_module.enable:
    - require:
      - pkg: keystone

stop-apache2:
  service.dead:
    - name: apache2
    - require:
      - pkg: keystone

apache2:
  file.symlink:
    - name: /etc/apache2/sites-enabled/keystone.conf
    - makedirs: True
    - target: /etc/apache2/sites-available/keystone.conf
  service.running:
    - enable: False
    - require:
      - service: keystone
      - cmd: keystone
      - file: keystone-cgi-main
      - file: keystone-cgi-admin
      - file: apache2
      - file: disable-apache-default-port
      - file: disable-apache-default-vhost
      - apache_module: wsgi
      - service: stop-apache2

/etc/salt/minion.d/keystone.conf:
  file.managed:
    - source: salt://openstack/keystone/minion.conf
    - template: jinja
    - require:
      - service: apache2
