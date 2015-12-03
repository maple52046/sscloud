nginx:
  pkgrepo.managed:
    - ppa: nginx/stable
    - refresh_db: True
  pkg.latest:
    - pkgs:
      - nginx
      - nginx-extras
    - require:
      - pkgrepo: nginx
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - require_in:
      - service: nginx
  service.running:
    - enable: False
    - require:
      - file: nginx
