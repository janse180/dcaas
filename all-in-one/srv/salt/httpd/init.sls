httpd:
  pkg:
    - installed
    - pkgs:
      - httpd
      - mod_ssl
  service:
    - running
    - enable: True
    - require:
      - pkg: httpd
      - cmd: htpasswd
    - watch:
      - file: graphite-web.conf
      - file: ssl.conf

ssl.conf:
  file.managed:
    - name: /etc/httpd/conf.d/ssl.conf
    - source: salt://httpd/ssl.conf

htpasswd:
  cmd:
    - run
    - name: /usr/bin/htpasswd -bc /etc/httpd/.htpasswd admin dcadmin
    - unless: test -f /etc/httpd/.htpasswd
    - require:
      - pkg: httpd
