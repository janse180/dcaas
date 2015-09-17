#!/bin/bash

yum install -y salt-master git salt-minion
./get_git_sub_dir.py eresearchsa/citc/all-in-one /opt
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
salt-call --local state.sls state.sls graphite,httpd,nfs.server,ntp,torque.server,maui,users

