mariadb:
  docker.pulled:
    - tag: latest

/var/run/mysqld:
  file.directory:
    - mode: 0777

openstack.cnf:
  file.recurse:
    - name: /etc/mysql/conf.d/
    - source: salt://mariadb/conf.d
    - makedirs: True

mariadb-server:
  docker.running:
    - image: "mariadb:latest"
    - network_mode: host
    - environment:
      - "MYSQL_ROOT_PASSWORD": {{ salt['pillar.get']('database:root:password', 'sscloud-admin-2357') }}
      - "MYSQL_ALLOW_EMPTY_PASSWORD": no
    - volumes:
      - "/etc/mysql/conf.d:/etc/mysql/conf.d"
      - "/var/lib/mysql:/var/lib/mysql"
      - "/var/run/mysqld:/var/run/mysqld"
    - require:
      - docker: mariadb
      - file: /var/run/mysqld
      - file: openstack.cnf

/etc/mysql/debian.cnf:
  file.managed:
    - makedirs: True
    - contents: |
        [client]
        host     = localhost
        user     = root
        password = {{ salt['pillar.get']('database:root:password', 'sscloud-admin-2357') }}
        socket   = /var/run/mysqld/mysqld.sock

/etc/salt/minion.d/mysql.conf:
  file.managed:
    - contents: |
        mysql.default_file: '/etc/mysql/debian.cnf'
        mysql.charset: 'utf8'
    - require:
      - docker: mariadb-server
      - file: /etc/mysql/debian.cnf
