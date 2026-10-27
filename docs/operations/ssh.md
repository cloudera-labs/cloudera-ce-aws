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

# SSH Access

The Terraform module creates a local SSH configuration file containing jump host details. Once FreeIPA is set up and hosts are enrolled, use this to access deployment hosts.

## Using the SSH Config

```bash
ssh -F <name_prefix>-ssh.config <hostname>
```

## SSH Config Structure

The generated config follows this pattern:

```ssh-config
# Jump host (gateway with public IP)
Host jump
  HostName <GATEWAY_PUBLIC_IP>
  User ec2-user
  IdentityFile /path/to/<name_prefix>-ssh-key.pem

# Internal hosts via jump proxy
Host *.<dns_domain>
  User ec2-user
  IdentityFile /path/to/<name_prefix>-ssh-key.pem
  ProxyJump jump
  ForwardAgent yes
```

## Direct Access

You can also SSH directly to the gateway:

```bash
ssh -i <name_prefix>-ssh-key.pem ec2-user@<GATEWAY_PUBLIC_IP>
```

Then hop to internal hosts from the gateway:

```bash
ssh <hostname>.<dns_domain>
```

!!! tip
    Host FQDNs use the internal domain (default: `cldr.arpa`). For example: `myprefix-base-master-0.cldr.arpa`.
