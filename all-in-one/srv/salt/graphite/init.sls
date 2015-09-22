graphite-packages:
  pkg:
    - installed
    - names:
      - python-carbon
      - python-whisper
      - graphite-web
    - require:
      - pkg: httpd

local_settings.py:
  file.managed:
    - name: /etc/graphite-web/local_settings.py
    - source: salt://graphite/local_settings.py
    - require:
      - pkg: graphite-packages

graphite.db:
  cmd.run:
    - name: python /usr/lib/python2.6/site-packages/graphite/manage.py syncdb --noinput
    - unless: test -f /var/lib/graphite-web/graphite.db
    - require:
      - pkg: graphite-packages
      - file: local_settings.py

storage-schemas.conf:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://graphite/storage-schemas.conf
    - require:
      - pkg: graphite-packages

storage-aggregation.conf:
  file.managed:
    - name: /etc/carbon/storage-aggregation.conf
    - source: salt://graphite/storage-aggregation.conf
    - require:
      - pkg: graphite-packages

carbon-cache:
  service:
    - enable: True
    - running
  require:
    - pkg: graphite-packages
    - cmd: graphite.db
  watch:
    - file: storage-schemas.conf
    - file: storage-aggregation.conf
    - file: local_settings.py

/var/lib/graphite-web:
  file.directory:
    - user: apache
    - group: apache
    - recurse:
      - user
      - group
  require:
    - pkg: graphite-packages

graphite-web.conf:
  file.managed:
    - name: /etc/httpd/conf.d/graphite-web.conf
    - source: salt://graphite/graphite-web.conf

#clean_db.sh:
#  file:
#    - managed
#    - name: /etc/cron.hourly/clean_db
#    - source: salt://graphite/clean_db.sh
#    - user: root
#    - group: root
#    - mode: 755

