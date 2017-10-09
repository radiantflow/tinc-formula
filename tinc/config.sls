{% from slspath+"/map.jinja" import tinc with context %}
{%- set host = grains['id'].split('.') | first %}

tinc-net-boot:
  file.managed:
    - name: /etc/tinc/nets.boot
    - source: salt://tinc/files/nets.boot
    - mode: 755
    - template: jinja
    - user: root
    - group: root
    - makedirs: true

{% for netname, network in tinc.get('networks', {}).items() %}

tinc-hosts-directory-{{netname}}:
  file.directory:
    - name: /etc/tinc/{{ netname }}/hosts/
    - makedirs: true
    - mode: 755
    - user: root
    - group: root

tinc-config-{{netname}}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/tinc.conf
    - mode: 755
    - user: root
    - group: root
    - clean: true
    - source: salt://tinc/template/tinc.conf.tmpl
    - template: 'jinja'
    - context:
        config: {{ network.get('config', {})|json }}
        hostname: {{ host|json }}
    - watch_in:
      - service: tinc

{%- if network.tinc_up is defined %}
tinc-up-network-{{ netname }}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/tinc-up
    - mode: 755
    - user: root
    - group: root
    - contents_pillar: tinc:networks:{{ netname }}:tinc_up
{%- endif %}

{%- if network.tinc_down is defined %}
tinc-down-network-{{ netname }}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/tinc-down
    - mode: 755
    - user: root
    - group: root
    - contents_pillar: tinc:networks:{{ netname }}:tinc_down
{%- endif %}

{%- if network.private_key is defined %}
tinc-private-key-{{ netname }}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/rsa_key.priv
    - mode: 700
    - user: root
    - group: root
    - contents: tinc:networks:{{ netname }}:private_key
{%- endif %}


{% for hostname, host in network['nodes'].items() %}

tinc-host-file-{{ netname }}-{{ hostname}}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/hosts/{{ hostname}}
    - mode: 755
    - user: root
    - group: root
    - clean: true
    - source: salt://tinc/template/host.tmpl
    - template: 'jinja'
    - context:
        config: {{ host.get('config', {})|json }}
        public_key: {{ host.get('public_key', "")|json }}

{% endfor %}

{% endfor %}
