emi.repo:
  cmd:
    - run
    - name: yum -y localinstall http://emisoft.web.cern.ch/emisoft/dist/EMI/3/sl6/x86_64/base/emi-release-3.0.0-2.el6.noarch.rpm
    - unless: test -e /etc/yum.repos.d/emi3-third-party.repo
        
maui.packages:
  pkg.installed:
    - pkgs:
      - maui-server
      - maui-client
    - require:
      - cmd: emi.repo
      
maui:
  service.running:
    - enable: True
    - require:
      - pkg: maui.packages
      - service: pbs_server
    - watch:
      - file: maui.cfg
      
maui.cfg:
  file.managed:
    - name: /var/spool/maui/maui.cfg
    - source: salt://maui/maui.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: maui.packages