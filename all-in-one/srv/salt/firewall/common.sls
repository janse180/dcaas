firewall.packages:
  pkg.installed:
    - pkgs:
      - iptables
      - ipset
      
iptables:
  service:
    - running
    - require:
      - pkg: firewall.packages
    - watch:
      - file: iptables
  file:
    - managed
    - template: jinja
    - name: /etc/sysconfig/iptables
    - user: root
    - group: root
    - mode: 600
      
