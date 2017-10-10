{% from slspath+"/map.jinja" import tinc with context %}


tinc:
  pkg:
    - installed
    - name: tinc
  service:
    - running
    - name: tinc
    - enable: True

{% if grains['os_family'] == 'RedHat' %}
tinc-init-redhat:
  file.managed:
    - name: /etc/init.d/tinc
    - source: salt://tinc/files/init.redhat
    - mode: 755
    - user: root
    - group: root
{% endif %}

tinc-tun:
  kmod.present:
    - name: tun
    - persist: true

# Create tinc user
tinc-user:
  group.present:
    - name: tinc-vpn
  user.present:
    - name: tinc-vpn
    - createhome: false
    - system: true
    - groups:
      - tinc-vpn
    - require:
      - group: tinc-vpn

# Create directories
tinc-config-dir:
  file.directory:
    - name: /etc/tinc
    - user: tinc-vpn
    - group: tinc-vpn
