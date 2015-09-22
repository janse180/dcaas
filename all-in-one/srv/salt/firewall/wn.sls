include:
  - firewall.common

extend:
  iptables:
    file:
      - source: salt://firewall/iptables.wn
