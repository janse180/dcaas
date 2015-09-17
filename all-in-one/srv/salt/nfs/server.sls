include:
  - nfs.common

data:
  file.directory:
    - name: /data
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

nfs_server:
  service.running:
    - name: nfs
    - enable: True
    - require:
      - pkg: nfs-utils
      - service: rpcbind

update_exports:
  cmd.run:
    - name: exportfs -ra
    - require:
      - pkg: nfs-utils
      - file: data
    - watch:
      - file: server_exports

server_exports:
  file.managed:
    - name: /etc/exports
    - source: salt://nfs/exports
    - user: root
    - group: root
    - mode: 644
    - template: jinja