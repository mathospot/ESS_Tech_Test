# ESS Tech Test

This repository contains the technical test for ESS system engineer position. It includes infrastructure code and configurations related to deploying services using tools like Terraform, Packer, and Puppet.

## Project Structure

- **credentials/**: Contains credentials required for deployments.
- **packer/**: Configuration files for building images using Packer.
- **puppet/**: Puppet manifests and modules for system configuration.
- **terraform/**: Infrastructure as Code (IaC) files for deploying resources using Terraform.

## How to Use

1. Clone the repository.
2. Adapt the packer and terraform templates with your own project id, image output name, credentials file, etc.
3. Ensure you have the necessary tools installed:
   - Terraform
   - Packer
   - Puppet

## Instructions

1. **Packer Image Build:**
   - Navigate to the `packer/` directory and run the build command:
     ```bash
     packer init <template.pkr.hcl>
     packer build <template.pkr.hcl>
     ```

2. **Terraform VM Deployment:**
   - Navigate to the `terraform/` directory and initialize:
     ```bash
     terraform init
     ```
   - Apply the configuration to deploy VMs based on the Packer image:
     ```bash
     terraform apply
     ```

3. **Puppet Configuration:**
   - Puppet should automatically run as part of the Packer-built image once the VMs are deployed, ensuring proper system configuration.
