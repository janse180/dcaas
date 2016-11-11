include:
  - torque.common
  
extend:
  torque.packages:
    pkg.installed:
      - pkgs:
        - torque-client
        - torque-server
  servername:
    file:
      - context: {
        server_name: "{{ grains['fqdn'] }}"
        }

setup torque server:
  cmd.run:
    - name: salt://torque/torque.setup
    - cwd: /
    - stateful: True
    - creates: /var/lib/torque/server_priv/serverdb

trqauthd:
  service.running:
    - enable: True
    - require:
      - pkg: torque.packages

pbs_server:
  service.running:
    - enable: True
    - require:
      - pkg: torque.packages
      - service: munge
      - service: trqauthd
    - watch:
      - file: servername
