#!/bin/bash

yum install -y epel-release
yum install -y salt-master git salt-minion
cd /opt
curl -L https://api.github.com/repos/janse180/dcaas/tarball/master | tar xfvz - janse180-dcaas-*/all-in-one
mv janse180-dcaas-*/all-in-one .
rmdir janse180-dcaas-*
rm -rf /srv
ln -s /opt/all-in-one/srv /srv
echo -n "runner_dirs: [\"/srv/runner\"]" >> /etc/salt/master
mkdir -p /etc/salt/master.d/
cat << EOF > /etc/salt/master.d/reactor.conf
reactor:
  - 'salt/auth':
      /srv/reactor/auth-pending.sls
  - 'salt/minion/dynamicwn-*/start':
    - /srv/reactor/wn-start.sls
  - 'collector/result':
    - /srv/reactor/collector.sls
EOF
service salt-master start
salt-call --local state.sls nova,firewall.hn,graphite,httpd,nfs.server,ntp,torque.server,maui,users
