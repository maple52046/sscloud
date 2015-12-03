libvirt-system-account:
  group.present:
    - name: kvm
    - gid: 499
  user.present:
    - name: libvirt-qemu
    - uid: 499
    - gid: 499
    - shell: /bin/false
    - home: /var/lib/libvirt
    - createhome: False
    - require:
      - group: libvirt-system-account

openstack-nova-system-account:
  group.present:
    - name: nova
    - gid: 500
  user.present:
    - name: nova
    - uid: 500
    - gid: 500
    - home: /var/lib/nova
    - shell: /bin/false
    - require:
      - group: openstack-nova-system-account
