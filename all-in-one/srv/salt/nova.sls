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

openstacksdk:
  cmd:
    - run
    - name: pip install openstacksdk
    - unless: pip freeze|grep -q openstacksdk
    - require:
      - cmd: pip
