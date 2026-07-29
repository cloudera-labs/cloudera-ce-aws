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

# Configuration

## Create config.yml

Copy the configuration template:

```bash
cp config-template.yml config.yml
```

## Mandatory Parameters

Fill in the following minimum parameters in `config.yml`:

```yaml
name_prefix: ""       # Unique identifier for the deployment (used in resource names and tags)
infra_region: ""      # AWS region (e.g. us-east-2, eu-west-1)
common_password: ""   # Min 8 chars, must include 1 number
owner_email: ""       # Your Cloudera email (used for resource tagging and pgAdmin login)
```

## Optional Overrides

All other parameters have sensible defaults defined in `group_vars/all.yml`. Override any of them in your `config.yml` as needed:

### Version Pins

```yaml
cloudera_manager_version: 7.13.2
cloudera_runtime_version: 7.3.2
jdk_version: 17
```

### Domain Configuration

```yaml
dns_domain: "cldr.internal"            # Internal domain managed by local FreeIPA
public_domain: "nip.io"             # External domain for reverse proxy endpoints
```

The `public_domain` must be an externally routable domain so that reverse proxy
endpoints are reachable from outside the cluster. By default, we use the
[sslip.io](https://sslip.io/) Magic DNS service, which maps hostnames containing
an embedded IP address back to that IP (e.g. `cm.10.0.0.1.nip.io` resolves to
`10.0.0.1`). This removes the need to configure external DNS records for
development and testing environments.

### Feature Toggles

```yaml
enable_prometheus: false                 # Node Exporter, Prometheus, Grafana
enable_freeipa_wildcard_profile: false   # Wildcard cert profile in FreeIPA (for ECS)
enable_postgres_tls: false               # PostgreSQL TLS enrollment via FreeIPA
enable_prereq_freeipa_client: true       # Include prereq_freeipa_client role
```

### TLS Configuration

```yaml
caddy_self_signed: true   # Use self-signed TLS for the reverse proxy
```

!!! note
    If you wish to use an intermediate CA for the reverse proxy TLS (TLS termination), please contact #sme_automation on Slack.

## SSH Credentials

The Terraform module generates a new SSH private key automatically. You will find the `.pem` file in the project root directory after running the `infrastructure.yml` playbook.

To use **existing** SSH credentials instead:

```yaml
ssh_pem_file: "{{ lookup('ansible.builtin.env', 'SSH_PRIVATE_KEY_FILE') }}"
```

!!! warning
    You must use a **passwordless, OpenSSH (RFC4716)** compliant SSH key.

!!! warning
    The SSH private key must be accessible within the Execution Environment container's mounted volumes. The controller's `~/.ssh` directory is typically mounted automatically.
