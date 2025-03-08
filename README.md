
```markdown
# Oracle Cloud Infrastructure (OCI) Swarm Cluster Deployment

![OCI Logo](https://upload.wikimedia.org/wikipedia/commons/5/5c/Oracle_cloud_logo.png)

Terraform configurations to deploy a Swarm cluster on Oracle Cloud Infrastructure (OCI) Free Tier.

## Project Overview

This repository contains two main components:
1. **Infrastructure-as-Code (IaC)** for OCI networking components
2. Virtual Machine deployment with ARM64 architecture

### Architecture Diagram
```plaintext
+---------------------+
| OCI Virtual Cloud   |
| Network (VCN)       |
| 10.0.0.0/16         |
+---------------------+
        |
        | Public Subnet
        | 10.0.0.0/24
        |
+---------------------+
| Swarm Node (SRV1)    |
| - Ubuntu 24.04 LTS  |
| - 4 vCPUs/4GB RAM   |
| - ARM64 Architecture|
+---------------------+
```

## Features

- 🚀 Automated VCN provisioning with Internet Gateway
- 🔒 Security rules for SSH, HTTP, and HTTPS
- 💾 200GB boot volume for instances
- 📦 ARM-optimized infrastructure
- 🔄 Automatic .env file generation with instance IPs

## Prerequisites

1. Oracle Cloud Infrastructure Account (Free Tier)
2. Terraform v1.5+ [Install Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. OCI CLI Configured [Setup Instructions](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
4. SSH Key Pair (`oci_vm_key` and `oci_vm_key.pub` in ~/.ssh/)
5. jq (for advanced .env processing) - `sudo apt-get install jq`

## Project Structure

```bash
├── infra/               # Network infrastructure
│   ├── main.tf          # VCN, Subnet, Security List
│   ├── outputs.tf       # Exports subnet/AD info
│   └── variables.tf     # OCI credentials/config
└── vm/                  # Compute instance
    ├── main.tf          # VM configuration
    ├── outputs.tf       # IP addresses output
    └── variables.tf     # Shared variables
```

## Usage

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/oci-swarm-cluster.git
cd oci-free-tier-provision
```

### 2. Configure Variables
Create `variables.tf` in both `infra/` and `vm/` directories:
```hcl
# Example variables:
compartment_id    = "ocid1.compartment.oc1..your_compartment_ocid"
region            = "sa-saopaulo-1"
tenancy_ocid      = "ocid1.tenancy.oc1..your_tenancy_ocid"
user_ocid         = "ocid1.user.oc1..your_user_ocid"
fingerprint       = "12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef"
private_key_path  = "~/.oci/oci_api_key.pem"
ssh_public_key    = "ssh-rsa AAAAB3NzaC... your@email"
```

### 3. Deploy Infrastructure
```bash
cd infra/
terraform init
terraform apply
```

### 4. Deploy Virtual Machine
```bash
cd ../vm/
terraform init
terraform apply
```

## Customization

1. **Instance Size**: Modify in `vm/main.tf`:
```hcl
shape_config {
  ocpus         = 4    # Change vCPU count
  memory_in_gbs = 4    # Change memory allocation
}
```

2. **Network Configuration**: Adjust CIDR blocks in `infra/main.tf`:
```hcl
vcn_cidrs     = ["10.0.0.0/16"]  # VCN CIDR
cidr_block    = "10.0.0.0/24"     # Subnet CIDR
```

## Clean Up
```bash
cd vm/ && terraform destroy
cd ../infra/ && terraform destroy
```

## License
GNU GENERAL PUBLIC LICENSE v3

---

**Note**: Replace all placeholder values (your_compartment_ocid, your_tenancy_ocid, etc.) with your actual OCI credentials before use.