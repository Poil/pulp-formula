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

{%- if server.admin.enabled == true %}

admin_packages:
  pkg.installed:
    - pkgs:
      - pulp-rpm-plugins
      - pulp-admin-client
      - pulp-docker-admin-extensions
      - pulp-puppet-admin-extensions
      - pulp-python-admin-extensions
      - pulp-rpm-admin-extensions
    - order: 3

/etc/pulp/admin/admin.conf:
  ini.options_present:
    - separator: ':'
    - sections:
        server:
          host: {{ server.admin.hostname }}
          verify_ssl: {{ server.admin.verify_ssl }}
    - order: 3

{%- endif %}