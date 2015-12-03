include:
  - openstack.neutron.ml2
  - openstack.neutron.ovsagent
  - openstack.neutron.sysctl

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

neutron:
  pkg.installed:
    - pkgs:
      - neutron-l3-agent
      - neutron-dhcp-agent
      - neutron-metadata-agent

{% for serv in ['l3', 'metadata'] %}
neutron-{{ serv }}:
  file.managed:
    - name: /etc/neutron/{{ serv }}_agent.ini
    - source: salt://openstack/neutron/{{ serv }}_agent.ini
    - template: jinja
    - makedirs: True
  service.running:
    - name: neutron-{{ serv }}-agent
    - enable: False
    - require:
      - file: neutron-{{ serv }}
      - pkg: neutron
      - pkg: neutron-plugin-ml2
      - service: neutron-plugin-openvswitch-agent
{% endfor %}

"ovs-vsctl --may-exist add-br br-ex":
  cmd.run:
    - require:
      - pkg: neutron-plugin-openvswitch-agent
    - require_in:
      - service: neutron-l3
