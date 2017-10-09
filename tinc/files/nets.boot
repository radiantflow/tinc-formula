## This file contains all names of the networks to be started on system startup.
{% for netname, network in salt['pillar.get']('tinc:networks', {}).items() %}
{{ netname }}
{% endfor %}