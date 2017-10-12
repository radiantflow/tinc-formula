{%- from slspath+"/map.jinja" import tinc with context -%}

{%- if salt['test.provider']('service') == 'systemd' %}
tinc-system-file:
  file.managed:
    - source: salt://{{ slspath }}/files/tinc.service.jinja
    - name: /etc/systemd/system/tinc.service
    - mode: 0644
    - template: jinja
    - context:
      limit_memlock: {{ tinc.get('limit_memlock', 0) }}

tinc@-system-file:
  file.managed:
    - source: salt://{{ slspath }}/files/tinc@.service.jinja
    - name: /etc/systemd/system/tinc@.service
    - mode: 0644
    - template: jinja
    - context:
      limit_memlock: {{ tinc.get('limit_memlock', 0) }}

{%- endif %}

tinc-service:
  service.running:
    - name: 'tinc'
    - enable: True

{% for network, network_settings in tinc.networks.items() %}
tinc-service-{{ network }}:
  service.running:
    - name: tinc@{{ network }}
    - enable: True
    - watch:
      - file: /etc/tinc/{{ network }}/*
      - file: /etc/tinc/{{ network }}/hosts/*
{% endfor %}



