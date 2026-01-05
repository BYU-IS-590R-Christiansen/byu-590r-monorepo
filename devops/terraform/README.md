# BYU 590R Infrastructure - Terraform

This Terraform configuration replicates the functionality of `setup-ec2-server.sh` to provision AWS infrastructure for the BYU 590R monorepo.

## What It Creates

1. **Security Group** (`byu-590r-sg`)
   - SSH access (port 22)
   - HTTP access (port 80)
   - HTTPS access (port 443)
   - Backend API access (port 4444)

2. **EC2 Instance** (`t2.micro`)
   - Ubuntu 22.04 LTS (AMI: `ami-04f34746e5e1ec0fe`)
   - Configured with user_data script to install:
     - Node.js 18
     - PHP 8.3 and extensions
     - Composer
     - MySQL
     - Apache with virtual hosts
     - Git
   - Creates database and user
   - Sets up Laravel directories and permissions

3. **Elastic IP**
   - Static IP address for the EC2 instance

4. **S3 Buckets**
   - Development bucket (`byu-590r-dev-<timestamp>`)
   - Production bucket (`byu-590r-prod-<timestamp>-<random>`)
   - Both configured with public access blocked
   - Book images uploaded to both buckets

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** >= 1.0 installed
3. **AWS credentials** configured (via `aws configure` or environment variables)
4. **SSH key pair** created in AWS (default: `byu-590r`)

## Usage

1. **Copy the example variables file:**
   ```bash
   cd devops/terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   ```hcl
   aws_region  = "us-west-1"
   key_name    = "byu-590r"
   project_name = "byu-590r"
   ```

3. **Make the upload script executable:**
   ```bash
   chmod +x scripts/upload_images.sh
   ```

4. **Initialize Terraform:**
   ```bash
   terraform init
   ```

5. **Review the plan:**
   ```bash
   terraform plan
   ```

6. **Apply the configuration:**
   ```bash
   terraform apply
   ```

7. **View outputs:**
   ```bash
   terraform output
   ```

## Outputs

After applying, Terraform will output:
- `instance_id` - EC2 instance ID
- `elastic_ip` - Elastic IP address
- `ec2_host` - EC2 host (same as elastic_ip)
- `s3_bucket_dev` - Development S3 bucket name
- `s3_bucket_prod` - Production S3 bucket name
- `github_secrets_instructions` - Instructions for setting up GitHub secrets

## Destroying Resources

To destroy all created resources:
```bash
terraform destroy
```

## Differences from Bash Script

1. **State Management**: Terraform maintains state, so it can track and update existing resources
2. **Idempotency**: Running `terraform apply` multiple times is safe
3. **Dependency Management**: Terraform automatically handles resource dependencies
4. **No Manual Cleanup**: Terraform can destroy all resources with one command

## Notes

- The EC2 instance setup script runs via `user_data` when the instance is first created
- S3 bucket uploads happen via `null_resource` provisioners after the instance is ready
- The script will wait for the instance to be running before associating the Elastic IP
- Book images are uploaded to both dev and prod buckets automatically

## GitHub Actions Setup

After running `terraform apply`, use the outputs to configure GitHub Actions secrets:

1. Go to your repository settings → Secrets and variables → Actions
2. Add the following secrets:
   - `EC2_HOST` = value from `terraform output -raw ec2_host`
   - `S3_BUCKET` = value from `terraform output -raw s3_bucket_prod`
   - `S3_BUCKET_DEV` = value from `terraform output -raw s3_bucket_dev`
   - `EC2_SSH_PRIVATE_KEY` = contents of `~/.ssh/byu-590r.pem`

