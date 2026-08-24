# Devopsrepo1

Terraform is applied through GitHub Actions using AWS IAM OIDC..

## GitHub configuration

Create these repository Actions variables under **Settings > Secrets and variables > Actions > Variables**:

- `AWS_ROLE_ARN`: ARN of the IAM role trusted by GitHub Actions
- `AWS_REGION`: AWS region, such as `ap-south-1` (optional; defaults to `ap-south-1`)

The IAM role trust policy must restrict access to this repository and the `main` branch. The workflow needs `id-token: write` permission so GitHub can exchange its OIDC token for temporary AWS credentials.

Pull requests run Terraform formatting, validation, and plan. A push to `main` also applies the saved plan.

## Create the EC2 instance

The configuration creates an Amazon Linux 2023 `t3.micro` instance in the default VPC in `ap-south-1`. It does not open inbound SSH access. To associate an existing EC2 key pair, create `terraform.tfvars` locally:

```hcl
key_name = "your-existing-key-pair-name"
```

Then run:

```powershell
terraform init
terraform plan
terraform apply
```

The instance ID and public IP are printed after apply. Add a security group with an SSH rule restricted to your own public IP before using SSH.

## Local checks

```powershell
terraform fmt -check
terraform init
terraform validate
```
