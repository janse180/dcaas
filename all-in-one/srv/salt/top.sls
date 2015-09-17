base:
  '*':
    - ntp
    - users
  'dynamicwn-*':
    - nfs.common
    - mount
    - torque.mom
