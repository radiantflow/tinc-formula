{% from slspath+"/map.jinja" import tinc with context %}

include:
  - {{ slspath }}.install
  - {{ slspath }}.config
  - {{ slspath }}.service
