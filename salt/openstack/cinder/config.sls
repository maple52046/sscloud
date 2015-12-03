/etc/cinder/cinder.conf:
  file.managed:
    - source: salt://openstack/cinder/cinder.conf
    - template: jinja
    - makedirs: True
