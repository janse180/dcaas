nfs-utils:
  pkg.installed

rpcbind:
  service.running:
    - enable: True
    - require:
      - pkg: nfs-utils

idmapd.conf:
  file.managed:
    - name: /etc/idmapd.conf
    - source: salt://nfs/idmapd.conf
    - user: root
    - group: root
    - mode: 644
    
rpcidmapd:
  service.running:
    - enable: True
    - require:
      - pkg: nfs-utils
    - watch:
      - file: idmapd.conf
    