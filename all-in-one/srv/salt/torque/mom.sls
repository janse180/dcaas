include:
  - torque.common
  
extend:
  torque.packages:
    pkg.installed:
      - pkgs:
        - torque-client
        - torque-mom
  servername:
    file:
      - context: {
        server_name: "{{ grains['master'] }}"
        }

mom.config:
  file:
    - managed
    - template: jinja
    - name: /etc/torque/mom/config
    - source: salt://torque/mom_config
    - context: {
      server_name: "{{ grains['master'] }}"
      }
    - require:
      - pkg: torque.packages

pbs_mom:
  service.running:
    - enable: True
    - sig: pbs_mom
    - require:
      - pkg: torque.packages
    - watch:
      - file: mom.config
      - file: servername
    