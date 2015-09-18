emi:
  pkgrepo.managed:
    - humanname: EMI 3 third-party
    - baseurl: http://emisoft.web.cern.ch/emisoft/dist/EMI/3/sl6/$basearch/third-party
    - gpgcheck: 0
    - priority: 90
    - enabled: 0
        
maui.packages:
  pkg.installed:
    - fromrepo: emi
    - pkgs:
      - maui-server
      - maui-client
    - require:
      - pkgrepo: emi
      
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