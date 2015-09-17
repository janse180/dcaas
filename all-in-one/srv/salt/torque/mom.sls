include:
  - torque.common
  
extend:
  torque.packages:
    pkg.installed:
      - pkgs:
        - torque-mom
  servername:
    file:
      - context: {
        server_name: "{{ grains['master']['fqdn'] }}"
        }

mom.config:
  file:
    - managed
    - template: jinja
    - name: /var/spool/torque/mom_priv/config
    - source: salt://torque/mom_config
    - context: {
      server_name: "{{ grains['master']['fqdn'] }}"
      }
    - user: root
    - group: root
    - mode: 644
    - makedirs: True


pbs_mom:
  service.running:
    - enable: True
    - sig: pbs_mom
    - require:
      - pkg: torque.packages
    - watch:
      - file: mom.config
      - file: servername
    