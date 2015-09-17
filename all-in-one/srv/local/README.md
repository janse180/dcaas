running salt locally

1. install salt-minion
2. change minion config /etc/salt/minion
```
file_client: local

file_roots:
  base:
    - /srv/local/
```
3. run state
```
salt-call --local state.sls httpd,graphite
```