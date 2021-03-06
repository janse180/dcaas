dynamiccluster.package:
  cmd:
    - run
    - name: yum localinstall -y https://github.com/eResearchSA/dcaas/raw/master/rpms/dynamiccluster-1.0.0-1.el6.noarch.rpm
    - unless: rpm -q dynamiccluster-1.0.0-1.el6.noarch

dynamiccluster.config:
  file:
    - managed
    - name: /etc/dynamiccluster/dynamiccluster.yaml
    - source: salt://dynamiccluster/dynamiccluster.yaml
    - user: root
    - group: root
    - mode: 600
    - require:
      - cmd: dynamiccluster.package
      
userdata_salt.sh:
  file:
    - managed
    - name: /etc/dynamiccluster/userdata_salt.sh
    - source: salt://dynamiccluster/userdata_salt.sh
    - template: jinja
    - require:
      - cmd: dynamiccluster.package

wn.sh:
  file:
    - managed
    - name: /etc/dynamiccluster/wn.sh
    - source: salt://dynamiccluster/wn.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: dynamiccluster.package

dynamiccluster:
  service.running:
    - enable: True
    - require:
      - cmd: dynamiccluster.package
    - watch:
      - file: dynamiccluster.config

/usr/share/dynamiccluster/scripts/check_maui.sh > /dev/null 2>&1:
  cron.present:
    - user: root
    - minute: '*/5'
    - require:
      - cmd: dynamiccluster.package
    