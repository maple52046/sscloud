rabbitmq:
  docker.pulled:
    - tag: 3.5-management

rabbitmq-server:
  docker.running:
    - image: "rabbitmq:3.5-management"
    - command: "rabbitmq-server"
    - network_mode: host
    - hostname: {{ grains['host'] }}
    - environment:
      - "RABBITMQ_DEFAULT_USER": {{ salt['pillar.get']('rabbitmq:user', 'openstack') }}
      - "RABBITMQ_DEFAULT_PASS": {{ salt['pillar.get']('rabbitmq:password', 'sscloud-admin-2357') }}
    - require:
      - docker: rabbitmq

/usr/bin/rabbitmqctl:
  file.managed:
    - source: salt://rabbitmq/rabbitmqctl
    - mode: 0755
