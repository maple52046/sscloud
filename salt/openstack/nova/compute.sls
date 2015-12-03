nova-compute:
  pkg.installed:
    - pkgs:
      - nova-compute
      - sysfsutils
      - nova-novncproxy
    - require:
      - file: nova-compute
  file.managed:
    - name: /etc/nova/nova.conf
    - source: salt://openstack/nova/nova.conf
    - template: jinja
    - makedirs: True

{% for serv in ['compute', 'novncproxy'] %}
nova-{{ serv }}-service:
  service.running:
    - name: nova-{{ serv }}
    - enable: False
    - require:
      - pkg: nova-compute
{% endfor %}
