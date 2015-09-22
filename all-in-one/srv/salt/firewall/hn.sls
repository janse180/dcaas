include:
  - firewall.common

ipset:
  cmd:
    - run
    - name: ipset create workernodes hash:ip hashsize 4096
    - unless: ipset list workernodes -n >/dev/null 2>&1
    - require:
      - pkg: firewall.packages

extend:
  iptables:
    file:
      - source: salt://firewall/iptables.hn
      - require:
        - pkg: firewall.packages
        - cmd: ipset
