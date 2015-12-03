neutron-plugin-openvswitch-agent:
  pkg.installed:
    - require_in:
      - service: neutron-plugin-openvswitch-agent
      - service: openvswitch-switch
  service.running:
    - enable: True

openvswitch-switch:
  service.running:
    - enable: True
    - require_in:
      - service: neutron-plugin-openvswitch-agent
