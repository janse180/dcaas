base:
  '*':
    - ntp
    - users
  'dynamicwn-*':
    - firewall.wn
    - nfs.common
    - mount
    - torque.mom
