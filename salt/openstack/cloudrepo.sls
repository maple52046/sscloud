ubuntu-cloud-keyring:
  pkg.latest:
    - require_in:
      - pkgrepo: ubuntu-cloud-keyring
  pkgrepo.managed:
    - humanname: OpenStack Cloud Repository
    - name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main
    - file: /etc/apt/sources.list.d/cloudarchive-kilo.list
    - refresh_db: True
