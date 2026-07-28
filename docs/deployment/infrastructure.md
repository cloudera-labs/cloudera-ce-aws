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

# Infrastructure

The infrastructure playbook provisions all AWS resources using Terraform.

## What It Creates

- **VPC** with public and private subnets
- **Security groups** for SSH, reverse proxy, and Knox gateway
- **EC2 instances** across the cluster topology:
    - 1 Gateway (public subnet, Elastic IP)
    - 1 Services host (FreeIPA, PostgreSQL, pgAdmin)
    - 3 Masters
    - 4 Workers
    - 1 Cloudera Manager host
    - 1 SDX/Knox host
- **SSH keypair** (generated or user-provided)
- **Ansible inventory** via Terraform's ansible provider

## Run

```bash
ansible-navigator run playbooks/infrastructure.yml -e @config.yml
```

## Tags

| Tag | Purpose |
|-----|---------|
| `infra` | All infrastructure tasks |

## Outputs

After running:

- `tf_cluster_aws/terraform.tfvars` — generated Terraform variable file
- `<name_prefix>-ssh-key.pem` — generated SSH private key (if not using an existing key)
- `<name_prefix>-ssh.config` — SSH config for jump host access

## Customizing Node Sizing

Edit the host module inputs directly in the `tf_cluster_aws/hosts_*.tf` files. Each host group is defined as a module block with `instance_type`, `quantity`, and `root_volume` inputs:

| File | Module | Default Instance Type | Qty | Root Volume |
|------|--------|-----------------------|-----|-------------|
| `hosts_common.tf` | `gateway` | `t3a.medium` | 1 | — |
| `hosts_common.tf` | `services` | `t3a.large` | 1 | 500 GB |
| `hosts_base.tf` | `manager` | `r5a.xlarge` | 1 | 300 GB |
| `hosts_base.tf` | `sdx` | `t3a.xlarge` | 1 | 500 GB |
| `hosts_base.tf` | `base_masters` | `t3a.xlarge` | 3 | 250 GB |
| `hosts_base.tf` | `base_workers` | `t3a.xlarge` | 4 | 250 GB |

For example, to increase master nodes to `r5a.xlarge` with 500 GB root volumes, edit `tf_cluster_aws/hosts_base.tf`:

```hcl
module "base_masters" {
  # ...
  instance_type = "r5a.xlarge"
  quantity      = 3

  root_volume = {
    volume_size = 500
  }
}
```
