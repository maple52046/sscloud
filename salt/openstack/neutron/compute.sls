include:
  - openstack.neutron.ml2
  - openstack.neutron.ovsagent
  - openstack.neutron.sysctl

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1
