{% if grains['host'] == salt['pillar.get']('openstack:controller', ['localhost']) %}
include:
  - docker
  - rabbitmq
  - mariadb
  - openstack.cloudrepo
  - openstack.admin
  - openstack.keystone
  - openstack.glance
  - openstack.cinder.controller
  - openstack.nova.controller
  - openstack.neutron.server
  - openstack.neutron.network
  - openstack.horizon

extend:
  # Running RabbitMQ container required Docker service is running.
  rabbitmq:
    docker.pulled:
      - require:
        - service: docker

  # MariaDB
  {% for serv in ['keystone', 'cinder', 'glance', 'nova', 'neutron'] %}
  {% if salt['pillar.get']('openstack:' + serv + ':database:backend', 'mysql') == 'mysql' %}
  {{ serv }}-db:
    {% for target in ['user', 'database', 'grains'] -%}
    mysql_{{ target }}.present:
      - require:
        - docker: mariadb-server
    {% endfor %}
  {% endif -%}
  {% endfor -%}

  # Built Keystone image required Docker service is running.
  keystone-image:
    docker.built:
      - require:
        - docker: sscloud-image

  registry-keystone-service:
    keystone.service_present:
      - require:
        - cmd: openstack-client

  # Create Keystone authentication for other OpenStack services required OpenStack Keystone is running.
  {% for serv in ['glance', 'cinder', 'nova', 'neutron'] %}
  {% for target in ['tenant', 'role', 'user', 'service', 'endpoint'] %}
  {{ serv }}-{{ target }}:
    keystone.{{ target }}_present:
      - require:
        - service: nginx
        - file: keystone-conifg-for-minion
        - cmd: openstack-client
  {% endfor %}
  {% endfor %}

  # Create admin authentication for system administrator required OpenStack Keystone is running.
  {% for target in ['tenant', 'role', 'user'] %}
  admin-{{ target }}:
    keystone.{{ target }}_present:
      - require:
        - service: nginx
        - file: keystone-conifg-for-minion
        - cmd: openstack-client
  {% endfor %}

  # Running OpenStack Glance required OpenStack Keystone endpoint is exist.
  {% for serv in ['glance-api', 'glance-registry'] %}
  {{ serv }}:
    service.running:
      - require:
        - keystone: registry-keystone-endpoint
  {% endfor %}

  # Running other OpenStack service required both OpenStack Keystone endpoint is exist and RabbitMQ is running:
  {% for serv in ['cinder-api', 'cinder-scheduler', 'nova-api', 'nova-cert', 'nova-conductor', 'nova-consoleauth', 'nova-scheduler', 'neutron-server'] %}
  {{ serv }}:
    service.running:
      - require:
        - keystone: registry-keystone-endpoint
        - docker: rabbitmq-server
  {% endfor %}

{% endif %}
