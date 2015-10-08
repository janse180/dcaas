compiler.packages:
  pkg.installed:
    - pkgs:
      - gcc-c++
      - python-devel
      - python-setuptools

pip:
  cmd:
    - run
    - name: easy_install pip==1.3.0
    - unless: command -v pip >/dev/null 2>&1
    - require:
      - pkg: compiler.packages

python-novaclient:
  cmd:
    - run
    - name: pip install python-novaclient
    - unless: pip freeze|grep -q python-novaclient
    - require:
      - cmd: pip
