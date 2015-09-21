data:
  mount.mounted:
    - name: /data
    - device: {{ grains['master'] }}:/data
    - fstype: nfs4
    - opts: rsize=32768,wsize=32768,noatime,nodiratime,soft,_netdev
    - persist: True
    - mkmnt: True
    