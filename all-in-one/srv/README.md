### Salt Master config

/etc/salt/master
```
runner_dirs: ["/srv/runner"]
```

/etc/salt/master.d/reactor.conf
```
reactor:
  - 'salt/auth':
      /srv/reactor/auth-pending.sls
  - 'salt/minion/dynamicwn-*/start':
    - /srv/reactor/wn-start.sls
  - 'collector/result':
    - /srv/reactor/collector.sls
```

install services
```
salt-call --local state.sls graphite,httpd,nfs.server,ntp,torque.server,maui,users
```