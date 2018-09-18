{% from slspath+"/map.jinja" import tinc, tinc_external_ips with context %}

include:
  - tinc

{% for netname, network in tinc.get('networks', {}).items() %}
  {% for hostname, host in network['nodes'].items() %}

{{ hostname }}-host-entry:
  host.present:
    - ip: {{ host.get('tinc_ip', "")|json }}
    - names:
      - {{ hostname + "." + netname }}

  {% endfor %}
{% endfor %}
