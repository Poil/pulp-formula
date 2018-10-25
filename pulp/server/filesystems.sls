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

{%- if server.filesystems.enabled == true %}

{%- set vg_name = server.filesystems.vg_name %}

mongo_lv:
  lvm.lv_present:
    - name: mongo
    - vgname: {{ vg_name }}
    - size: {{ server.filesystems.mongo_size }}
    - order: 1

mongo_fs:
  blockdev.formatted:
    - name: /dev/mapper/{{ vg_name }}-mongo
    - fs_type: {{ server.filesystems.fs_type }}
    - require:
      - lvm: mongo_lv
    - order: 1

/var/lib/mongodb:
  mount.mounted:
    - device: /dev/mapper/{{ vg_name }}-mongo
    - fstype: {{ server.filesystems.fs_type }}
    - mkmnt: true
    - persist: true
    - opts:
      - defaults
    - require:
      - blockdev: mongo_fs
    - order: 1

pulp_lv:
  lvm.lv_present:
    - name: pulp
    - vgname: {{ vg_name }}
    - size: {{ server.filesystems.pulp_size }}
    - order: 1

pulp_fs:
  blockdev.formatted:
    - name: /dev/mapper/{{ vg_name }}-pulp
    - fs_type: {{ server.filesystems.fs_type }}
    - require:
      - lvm: pulp_lv
    - order: 1

/var/lib/pulp:
  mount.mounted:
    - device: /dev/mapper/{{ vg_name }}-pulp
    - fstype: {{ server.filesystems.fs_type }}
    - mkmnt: true
    - persist: true
    - opts:
      - defaults
    - require:
      - blockdev: pulp_fs
    - order: 1

{%- endif %}