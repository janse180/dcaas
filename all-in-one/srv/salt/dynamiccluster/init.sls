dynamiccluster.package:
  cmd:
    - run
    - name: yum localinstall -y https://github.com/eResearchSA/citc/raw/master/rpms/dynamiccluster-0.5.0-1.el6.noarch.rpm
    - unless: rpm -q dynamiccluster-0.5.0-1.el6.noarch

dep.packages:
  pkg.installed:
    - pkgs:
      - gcc-c++
      - python-devel
      - python-pip
      
python-novaclient:
  pip.installed:
    - require:
      - pkg: dep.packages

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
    - require:
      - cmd: dynamiccluster.package

wn.sh:
  file:
    - managed
    - name: /etc/dynamiccluster/wn.sh
    - source: salt://dynamiccluster/wn.sh
    - require:
      - cmd: dynamiccluster.package

dynamiccluster:
  service.running:
    - enable: True
    - require:
      - cmd: dynamiccluster.packages
      - pip: python-novaclient
    - watch:
      - file: dynamiccluster.config
