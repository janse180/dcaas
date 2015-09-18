torque.packages:
  pkg.installed:
    - pkgs:
      - torque-client
      
munge.key:
  file.managed:
    - name: /etc/munge/munge.key
    - source: salt://torque/munge.key
    - user: munge
    - group: munge
    - mode: 600
    - require:
      - pkg: torque.packages

munge:
  service.running:
    - enable: True
    - require:
      - pkg: torque.packages
    - watch:
      - file: munge.key

servername:
  file:
    - managed
    - name: /var/lib/torque/server_name
    - source: salt://torque/server_name
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: torque.packages
      