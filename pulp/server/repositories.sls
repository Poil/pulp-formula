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

{%- set auth_info = "-u "+ server.admin.username +" -p "+ server.admin.password %}

{%- for repository in server.repositories %}

{%- set repository_type = repository.type if repository.get('type', false) else 'rpm' %}
{%- set relative_url = repository.relative_url if repository.get('relative_url', false) else repository.id.replace('-', '/') %}

{{ repository.id }}:
  cmd.run:
    - name: |
        /usr/bin/pulp-admin {{ auth_info }} {{ repository_type }} repo create \
            --validate true --retain-old-count 5 \
            --download-policy immediate --serve-http true \
            --serve-https true --repoview true \
            --repo-id {{ repository.id }} \
            {%- if repository.get('feed', false) -%}
            --feed {{ repository.feed }} \
            {%- endif -%}
            --relative-url {{ relative_url }}
        {%- if repository.get('feed', false) %}
        /usr/bin/pulp-admin {{ auth_info }} {{ repository_type }} repo sync \
            run --bg --repo-id {{ repository.id }}
        {%- endif %}
    - unless: |
        /usr/bin/pulp-admin {{ auth_info }} {{ repository.type }} repo list \
            --repo-id {{ repository.id }}
    - order: last

{%- endfor %}