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

# ------- General and Provider Resources -------

variable "prefix" {
  type        = string
  description = "Deployment prefix for all cloud-provider assets"

  validation {
    condition     = length(var.prefix) < 8 || length(var.prefix) > 4
    error_message = "Valid length for prefix is between 4-7 characters."
  }
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "asset_tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags applied to all cloud-provider assets"
}

# ------- SSH Resources -------

variable "ssh_private_key_file" {
  type        = string
  description = "Local SSH private key file path"
  default     = null
}

# ------- Network Resources -------

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block (primary)"
  default     = "10.10.0.0/16"
}

variable "igw_name" {
  type        = string
  description = "Internet Gateway name"
  default     = ""
}

variable "public_domain" {
  type        = string
  description = "Domain for public hosts"
  default     = "nip.io"
}

variable "vpc_ingress_cidr" {
  type        = list(string)
  description = "List of CIDR to limit ingress for SSH, HTTP Proxy, Knox Proxy, and FreeIPA"
}

variable "private_domain" {
  type        = string
  description = "Domain for private hosts"
  default     = "cldr.internal"
}

variable "ssh_security_group_name" {
  type        = string
  description = "Security Group name for SSH"
  default     = ""
}

variable "knox_gateway_security_group_name" {
  type        = string
  description = "Security Group name for the Knox Gateway"
  default     = ""
}

variable "knox_gateway_port" {
  type        = number
  description = "Knox Gateway HTTPS port"
  default     = 8443
}

variable "reverse_proxy_security_group_name" {
  type        = string
  description = "Security Group name for the Reverse Proxy"
  default     = ""
}

variable "reverse_proxy_port" {
  type        = number
  description = "Reverse Proxy port"
  default     = 443
}
