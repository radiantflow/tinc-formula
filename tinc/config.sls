{% from slspath+"/map.jinja" import tinc, tinc_external_ips with context %}
{%- set current_host = grains['id'].split('.') | first %}

tinc-debug:
  file.managed:
    - name: /etc/tinc/debug
    - contents: "{{ tinc.networks.default | yaml(False) }}"
    - mode: 755
    - clean: true
    - user: root
    - group: root

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
        connect_to: {{ network.get('connect_to', {}) | json}}
        config: {{ network.get('config', {})|json }}
        hostname: {{ current_host|json }}
    - watch_in:
      - service: tinc

tinc-up-network-{{ netname }}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/tinc-up
    - mode: 755
    - user: root
    - group: root
    - source: salt://tinc/files/tinc-up.jinja
    - template: 'jinja'
    - context:
        config: {{ network.get('config', {})|json }}
        hostname: {{ current_host|json }}
        tinc_subnet: {{ network.get('tinc_subnet', "")|json }}
        tinc_mask: {{ network.get('tinc_mask', "")|json }}
        tinc_ip: {{ network['nodes'][current_host].get('tinc_ip', "")|json }}
        remote_subnets: {{ network.get('remote_subnets', {})|json }}

tinc-down-network-{{ netname }}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/tinc-down
    - mode: 755
    - user: root
    - group: root
    - source: salt://tinc/files/tinc-down.jinja
    - template: 'jinja'
    - context:
        config: {{ network.get('config', {})|json }}
        hostname: {{ current_host|json }}
        tinc_subnet: {{ network.get('tinc_subnet', "")|json }}
        tinc_mask: {{ network.get('tinc_mask', "")|json }}
        tinc_ip: {{ network['nodes'][current_host].get('tinc_ip', "")|json }}
        remote_subnets: {{ network.get('remote_subnets', {})|json }}

{%- if network.private_key is defined %}
tinc-private-key-{{ netname }}:
  file.managed:
    - name: /etc/tinc/{{ netname }}/rsa_key.priv
    - mode: 700
    - user: root
    - group: root
    - contents_pillar: tinc:networks:{{ netname }}:private_key
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
        address: {{ host.get('address', host.get('ip', ""))|json }}
        subnets: {{ host.get('subnets', {})|json }}
        tinc_ip: {{ host.get('tinc_ip', "")|json }}
        config: {{ host.get('config', {})|json }}
        public_key: {{ host.get('public_key', "")|json }}


{% endfor %}

{% endfor %}
