#
# Copyright 2018 Fairtide Pte. Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

{%- from "pulp/map.jinja" import server with context %}

{%- if server.enabled == true %}

include:
  - pulp.server.filesystems
  - pulp.server.admin
  - pulp.server.repositories

pulp_packages:
  pkg.installed:
    - pkgs:
      - mongodb-server
      - qpid-cpp-server
      - qpid-cpp-server-linearstore
      - pulp-server 
      - python-gofer-qpid 
      - python2-qpid
      - qpid-tools
      - pulp-docker-plugins
      - pulp-puppet-plugins
      - pulp-python-plugins
    - order: 2
      
pulp_command_gen_key_pair:
  cmd.run:
    - name: /usr/bin/pulp-gen-key-pair
    - runas: root
    - creates:
      - /etc/pki/pulp/rsa.key
      - /etc/pki/pulp/rsa_pub.key
    - require:
      - pkg: pulp_packages
    - order: 2

pulp_command_gen_ca_certificate:
  cmd.run:
    - name: /usr/bin/pulp-gen-ca-certificate
    - runas: root
    - creates:
      - /etc/pki/pulp/ca.key
      - /etc/pki/pulp/ca.crt
    - require:
      - pkg: pulp_packages
    - order: 2

pulp_command_manage_db:
  cmd.run:
    - name: /usr/bin/pulp-manage-db
    - runas: apache
    - unless: /usr/bin/pulp-manage-db --dry-run
    - require:
      - pkg: pulp_packages
      - service: pulp_service_mongodb
      - service: pulp_service_qpidd
    - order: 2

pulp_service_mongodb:
  service.running:
    - name: mongod
    - enable: true
    - require:
      - pkg: pulp_packages
    - order: 2

pulp_service_qpidd:
  service.running:
    - name: qpidd
    - enable: true
    - require:
      - pkg: pulp_packages
    - order: 2

pulp_service_httpd:
  service.running:
    - name: httpd
    - enable: true
    - require:
      - pkg: pulp_packages
      - cmd: pulp_command_gen_key_pair
      - cmd: pulp_command_gen_ca_certificate
      - cmd: pulp_command_manage_db
      - service: pulp_service_mongodb
      - service: pulp_service_qpidd
    - order: 2

pulp_service_workers:
  service.running:
    - name: pulp_workers
    - enable: true
    - require:
      - pkg: pulp_packages
      - cmd: pulp_command_gen_key_pair
      - cmd: pulp_command_gen_ca_certificate
      - cmd: pulp_command_manage_db
      - service: pulp_service_mongodb
      - service: pulp_service_qpidd
    - order: 2

pulp_service_celerybeat:
  service.running:
    - name: pulp_celerybeat
    - enable: true
    - require:
      - pkg: pulp_packages
      - cmd: pulp_command_gen_key_pair
      - cmd: pulp_command_gen_ca_certificate
      - cmd: pulp_command_manage_db
      - service: pulp_service_mongodb
      - service: pulp_service_qpidd
    - order: 2

pulp_service_resource_manager:
  service.running:
    - name: pulp_resource_manager
    - enable: true
    - require:
      - pkg: pulp_packages
      - cmd: pulp_command_gen_key_pair
      - cmd: pulp_command_gen_ca_certificate
      - cmd: pulp_command_manage_db
      - service: pulp_service_mongodb
      - service: pulp_service_qpidd
    - order: 2

{%- endif %}