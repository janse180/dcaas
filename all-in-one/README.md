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
salt-call --local state.sls nova,graphite,httpd,nfs.server,ntp,torque.server,maui,users
```

run bootstrap script
```
curl https://raw.githubusercontent.com/eResearchSA/citc/master/all-in-one/bootstrap.sh | sh -
```

install dynamic cluster
```
salt-call --local state.sls dynamiccluster
```