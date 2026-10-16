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

# Clusters

After deploying infrastructure, services, and Cloudera Manager, deploy one of the provided cluster topologies.

## Cluster Playbook Steps

Each cluster playbook follows a consistent pattern:

1. **Host Service Prerequisites** — creates required system users/groups and provisions databases for cluster services
2. **CSD/Parcel Management** — downloads Custom Service Descriptors and activates parcels
3. **Cluster Provisioning & Service Configuration** — establishes the cluster, registers hosts, and configures services in dependency order
4. **Host Role Topology Setup** — defines host templates and assigns roles to specific nodes
5. **Cluster Initialization & Startup** — performs first-run execution, restarts stale services, and validates health

```yaml
# Example: Host preparation with service-specific prerequisites
- name: Configure hosts for cluster services
  hosts: base
  gather_facts: true
  become: true
  roles:
    - role: cloudera.exe.prereq_kafka
    - role: cloudera.exe.prereq_hdfs
    - role: cloudera.exe.prereq_ranger
    # Additional service prerequisites based on cluster type
    # - role: cloudera.exe.prereq_nifi        # NiFi clusters
    # - role: cloudera.exe.prereq_flink       # Flink clusters
```

```yaml
# Example: Database configuration
- name: Configure databases for cluster services
  hosts: postgresql
  become: true
  roles:
    - role: cloudera.exe.prereq_ranger_database
    - role: cloudera.exe.prereq_hive_database
    - role: cloudera.exe.prereq_knox_database
    # - role: cloudera.exe.prereq_schemaregistry_database  # NiFi clusters
    # - role: cloudera.exe.prereq_ssb_database             # Flink clusters
```

## Available Clusters

### Ozone Cluster

An Ozone-enabled base cluster with HDFS, YARN, and Ozone storage.

```bash
ansible-navigator run playbooks/ozone-cluster.yml -e @config.yml
```
### Streaming Cluster

A base cluster combining additional Flink/SQL Stream Builder, Streams Messaging Manager, and NiFi — the Full Cluster's streaming services.

```bash
ansible-navigator run playbooks/streaming-cluster.yml -e @config.yml
```

**Services**: ZooKeeper, HDFS, YARN, Tez, Ozone, Kafka, HBase, Solr, Ranger, Atlas, Hive, Hive-on-Tez, Knox, Flink, Kudu, Impala, SQL Stream Builder, Streams Messaging Manager, NiFi, NiFi Registry

**CSDs**: CSA (Flink/SSB) `1.17.0.0`, CFM (NiFi) `4.12.0.0`

**Parcels**: CDH `7.3.2`, FLINK `1.20.1-csa1.17.0.0`, CFM `4.12.0.0`

!!! warning "Requires a larger instance type"
    Running this many services on a single set of nodes exceeds the memory and CPU capacity of the default `t3a.xlarge` instance type used for the `sdx`, `base_masters`, and `base_workers` host groups.

    Before deploying this cluster, edit `tf_cluster_aws/hosts_base.tf` and change `instance_type` from `t3a.xlarge` to `t3a.2xlarge` for the `sdx`, `base_masters`, and `base_workers` modules (the `manager` module can stay on `r5a.xlarge`). Re-run the infrastructure playbook to resize the nodes before running `streaming-cluster.yml`. See [Customizing Node Sizing](infrastructure.md#customizing-node-sizing) for details.

**Host Template Distribution**:

| Template | Roles |
|----------|-------|
| **SDX** | Atlas Server, HDFS Balancer, Flink Gateway, Hive Gateway, Impala Catalog Server/StateStore, Knox Gateway, NiFi Registry Server/Gateway, Ozone Gateway/Recon/S3 Gateway, Ranger Admin/TagSync/UserSync, SMM Server/UI, SSB Materialized View Engine/Streaming SQL Engine, Tez Gateway |
| **Master1** | HBase Master, HDFS NameNode, Kudu Master, Ozone Manager, Ozone SCM, ZooKeeper Server |
| **Master2** | Flink History Server, HBase Master, Kudu Master, Ozone Manager, Ozone SCM, YARN JobHistory/ResourceManager, ZooKeeper Server |
| **Master3** | HBase Master, HDFS Secondary NameNode, Hive Metastore, Hive-on-Tez HiveServer2, Kafka KRaft, Kudu Master, Ozone Manager, Ozone SCM, Solr Server, ZooKeeper Server |
| **Worker** | HBase RegionServer, HDFS DataNode, Impala Daemon, Kafka Broker, Kudu Tablet Server, NiFi Node, Ozone DataNode, YARN NodeManager |

### Full Cluster

Base cluster running both CSA and CFM streaming services and Data Visualization service.

```bash
ansible-navigator run playbooks/full-cluster.yml -e @config.yml
```

**Services**: ZooKeeper, HDFS, YARN, Tez, Ozone, Kafka, HBase, Solr, Ranger, Atlas, Hive, Hive-on-Tez, Knox, Flink, Kudu, Impala, Spark3, Livy, SQL Stream Builder, Streams Messaging Manager, NiFi, NiFi Registry, Hue, Data Visualization

**CSDs**: CSA (Flink/SSB) `1.17.0.0`, Data Visualization `8.1.1.1000`, CFM (NiFi) `4.12.0.0`

**Parcels**: CDH `7.3.2`, FLINK `1.20.1-csa1.17.0.0`, DATAVIZ `8.1.1.1000`, CFM `4.12.0.0`

!!! warning "Requires a larger instance type"
    Running every service on a single set of nodes exceeds the memory and CPU capacity of the default `t3a.xlarge` instance type used for the `sdx`, `base_masters`, and `base_workers` host groups.

    Before deploying this cluster, edit `tf_cluster_aws/hosts_base.tf` and change `instance_type` from `t3a.xlarge` to `t3a.2xlarge` for the `sdx`, `base_masters`, and `base_workers` modules (the `manager` module can stay on `r5a.xlarge`). Re-run the infrastructure playbook to resize the nodes before running `full-cluster.yml`. See [Customizing Node Sizing](infrastructure.md#customizing-node-sizing) for details.

**Host Template Distribution**:

| Template | Roles |
|----------|-------|
| **SDX** | Atlas Server, HDFS Balancer, Dataviz Reverse Proxy/Webserver, Flink Gateway, Hive Gateway, Hue Load Balancer/Server/KT Renewer, Impala Catalog Server/StateStore, Knox Gateway, Livy Gateway/Server, NiFi Registry Server/Gateway, Ozone Gateway/Recon/S3 Gateway, Ranger Admin/TagSync/UserSync, SMM Server/UI, Spark3 History Server, SSB Materialized View Engine/Streaming SQL Engine, Tez Gateway |
| **Master1** | HBase Master, HDFS NameNode, Kudu Master, Ozone Manager, Ozone SCM, ZooKeeper Server |
| **Master2** | Flink History Server, HBase Master, Kudu Master, Ozone Manager, Ozone SCM, YARN JobHistory/ResourceManager, ZooKeeper Server |
| **Master3** | HBase Master, HDFS Secondary NameNode, Hive Metastore, Hive-on-Tez HiveServer2, Kafka KRaft, Kudu Master, Ozone Manager, Ozone SCM, Solr Server, ZooKeeper Server |
| **Worker** | HBase RegionServer, HDFS DataNode, Impala Daemon, Kafka Broker, Kudu Tablet Server, NiFi Node, Ozone DataNode, YARN NodeManager |

## Runtime

Each cluster deployment takes approximately **10–20 minutes** depending on the number of services.

!!! tip
    All cluster playbooks are idempotent — running them again will not modify an already-configured cluster.
