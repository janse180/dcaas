httpd:
  pkg:
    - installed
    - pkgs:
      - httpd
      - mod_ssl
  service:
    - running
    - require:
      - pkg: httpd

