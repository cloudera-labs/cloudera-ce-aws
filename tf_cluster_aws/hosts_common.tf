# Copyright 2026 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ------- Host AMI -------

locals {
  ami_user   = "ec2-user"
  ami_owners = ["309956199498"]
  ami_filters = {
    name         = ["RHEL-9.6.0_HVM-*"]
    architecture = ["x86_64"]
  }
}

data "aws_ami" "pvc_base" {
  owners      = local.ami_owners
  most_recent = true

  dynamic "filter" {
    for_each = local.ami_filters

    content {
      name   = filter.key
      values = filter.value
    }
  }
}

# ------- Gateway Host -------

module "gateway" {
  source     = "git::https://github.com/cloudera-labs/terraform-cloudera-ce-infrastructure-aws.git//modules/hosts?ref=main"
  depends_on = [aws_key_pair.pvc_base, data.aws_ami.pvc_base]

  providers = {
    aws                    = aws,
    aws.pricing_calculator = aws.price_calculator
  }

  name          = "${var.prefix}-gateway"
  quantity      = 1
  image_id      = data.aws_ami.pvc_base.image_id
  instance_type = "t3a.medium"
  subnet_ids    = module.cluster_network.public_subnets[*].id
  ssh_key_pair  = aws_key_pair.pvc_base.key_name
  security_groups = [
    module.cluster_network.intra_cluster_security_group.id,
    module.cluster_network.acme_tls_security_group.id,
    aws_security_group.ssh_proxy.id,
    aws_security_group.knox_gateway.id,
    aws_security_group.reverse_proxy.id
  ]
  public_ip = true
}

resource "aws_eip" "pvc-base" {
  for_each = { for idx, host in concat(module.gateway.hosts) : idx => host }

  instance = each.value.id
  domain   = "vpc"
  tags     = { Name = each.value.tags.Name }
}

resource "ansible_host" "gateway" {
  for_each = { for idx, host in module.gateway.hosts : idx => host }

  name = format("%s.%s", each.value.tags["Name"], local.vpc_private_domain)

  groups = [
    ansible_group.reverse_proxy.name,
    ansible_group.ssh_proxy.name
  ]

  variables = {
    ansible_host = aws_eip.pvc-base[each.key].public_ip
    ansible_user = local.ami_user
    public_fqdn  = format("%s.%s.%s", each.value.tags["Name"], replace(aws_eip.pvc-base[each.key].public_ip, ".", "-"), var.public_domain)
  }
}

# ------- Services Host -------

module "services" {
  source     = "git::https://github.com/cloudera-labs/terraform-cloudera-ce-infrastructure-aws.git//modules/hosts?ref=main"
  depends_on = [aws_key_pair.pvc_base, data.aws_ami.pvc_base]

  providers = {
    aws                    = aws,
    aws.pricing_calculator = aws.price_calculator
  }

  name            = "${var.prefix}-services"
  quantity        = 1
  image_id        = data.aws_ami.pvc_base.image_id
  instance_type   = "t3a.large"
  ssh_key_pair    = aws_key_pair.pvc_base.key_name
  subnet_ids      = module.cluster_network.private_subnets[*].id
  security_groups = [module.cluster_network.intra_cluster_security_group.id]
  public_ip       = false

  root_volume = {
    volume_size = 500
  }
}

resource "ansible_host" "services" {
  for_each = { for idx, host in module.services.hosts : idx => host }

  name = format("%s.%s", each.value.tags["Name"], local.vpc_private_domain)

  groups = [
    ansible_group.freeipa.name,
    ansible_group.postgres.name,
    ansible_group.pgadmin.name
  ]

  variables = {
    ansible_host = each.value.private_ip
    ansible_user = local.ami_user
  }
}

# ------- Common Costed Modules -------

locals {
  common_costed_modules = {
    gateway  = module.gateway
    services = module.services
  }
}
