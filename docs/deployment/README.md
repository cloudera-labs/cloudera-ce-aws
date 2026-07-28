<!-- Copyright 2026 Cloudera, Inc.

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

         https://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License. -->

# Deployment Overview

The deployment runs in four stages, each handled by a dedicated playbook:

| Stage | Playbook | Duration | Purpose |
|-------|----------|----------|---------|
| 1. Infrastructure | `infrastructure.yml` | ~10 min | AWS networking and hosts via Terraform |
| 2. Services | `services.yml` | ~15 min | DNS, Kerberos, database, proxy, monitoring |
| 3. Cloudera Manager | `cms.yml` | ~10 min | CM server, agents, AutoTLS, LDAP |
| 4. Cluster | `*-cluster.yml` | ~15 min | CDP Runtime cluster deployment |

## Run All Stages

To deploy everything in one command:

```bash
ansible-navigator run playbooks/infrastructure.yml playbooks/services.yml playbooks/cms.yml playbooks/ozone-cluster.yml -e @config.yml
```

Total runtime: approximately **40–50 minutes**.

## Run Stages Individually

Each stage can be run independently:

Provision infrastructure:

```bash
ansible-navigator run playbooks/infrastructure.yml -e @config.yml
```

Configure services:

```bash
ansible-navigator run playbooks/services.yml -e @config.yml
```

Install Cloudera Manager:

```bash
ansible-navigator run playbooks/cms.yml -e @config.yml
```

Deploy cluster:

```bash
ansible-navigator run playbooks/ozone-cluster.yml -e @config.yml
```

## Available Cluster Topologies

After stages 1–3, deploy any one of the following clusters:

| Playbook | Description |
|----------|-------------|
| `ozone-cluster.yml` | Ozone-enabled base cluster |
| `kafka-cluster.yml` | Kafka base cluster |
| `flink-cluster.yml` | Flink base cluster |
| `nifi-cluster.yml` | NiFi (CFM) cluster |
| `nifi2.0-cluster.yml` | NiFi 2.0 cluster |
| `csa-cluster.yml` | CSA (Cloudera Streaming Analytics) full cluster |

!!! tip
    The cluster playbooks are designed to be run after the base deployment (infrastructure + services + CMS).
