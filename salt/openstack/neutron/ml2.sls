neutron-plugin-ml2:
  pkg.installed:
    - require:
      - file: neutron-plugin-ml2
  file.managed:
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
    - source: salt://openstack/neutron/ml2_conf.ini
    - template: jinja
    - makedirs: True
