docker:
  cmd.run:
    - name: dpkg-query -s docker-engine || curl -sSL https://get.docker.com/ | sh
  service.running:
    - require:
      - cmd: docker

docker-py:
  cmd.run:
    - name: pip install docker-py==1.6.0
