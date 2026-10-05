# Terraform + Ansible AWS Deployment

**Terraform + Ansible Integration**

Automatically deploy a Node.js application on an AWS EC2 instance using **Terraform** for infrastructure and **Ansible** for configuration, all triggered by a single command:

```bash
terraform apply
```

Terraform creates the server, then uses the `local-exec` provisioner to run the Ansible playbook, which configures the machine and starts the app.

---

## Table of Contents

- [Technologies Used](#technologies-used)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Access the Application](#access-the-application)
- [Destroy the Infrastructure](#destroy-the-infrastructure)
- [Security Notes](#security-notes)
- [Uploading to GitHub](#uploading-to-github)

---

## Technologies Used

| Tool | Purpose |
|------|---------|
| AWS EC2 | Hosts the application server |
| Terraform | Provisions infrastructure |
| Ansible | Configures the server and deploys the app |
| Ubuntu | Server operating system |
| Node.js | Application runtime |
| Git | Clones the application repository |
| SSH | Connects Ansible to the server |

---

## How It Works

1. Terraform creates a **security group** and an **Ubuntu EC2 instance**.
2. Terraform gets the instance's **public IP** and writes it into `inventory.ini`.
3. Terraform runs the **Ansible playbook** using `local-exec`.
4. Ansible waits for the server, installs the required software, and starts the Node.js app.

---

## Project Structure

```
terraform-ansible-aws-deployment/
│
├── main.tf          # Terraform infrastructure configuration
├── playbook.yml     # Ansible deployment playbook
├── inventory.ini    # Ansible inventory
└── README.md        # Project documentation
```

### `main.tf`

Terraform configuration that:

- Creates an AWS security group
- Allows SSH traffic on port `22`
- Allows application traffic on port `3000`
- Creates an Ubuntu EC2 instance
- Automatically runs the Ansible playbook
- Passes the new EC2 public IP to Ansible

### `inventory.ini`

Ansible inventory containing the new EC2 instance's public IP and SSH settings.

### `playbook.yml`

Ansible playbook that:

- Waits for the EC2 instance to become available
- Updates the Ubuntu package cache
- Installs Git, curl and Node.js
- Clones the Node.js application
- Installs npm dependencies
- Starts the Node.js application

---

## Prerequisites

Install the following on the Ubuntu machine you will run Terraform and Ansible from:

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

You also need:

- An AWS account
- An existing AWS EC2 key pair
- The matching `.pem` private key
- AWS credentials configured on your machine

### Configure AWS Credentials

```bash
aws configure
```

Enter your:

- AWS Access Key ID
- AWS Secret Access Key
- Default region
- Output format

> **Important:** Never put AWS access keys or secret keys in `main.tf` or any file you push to GitHub.

### Set Up the SSH Key

Give your private key the correct permissions:

```bash
chmod 400 /path/to/your-key.pem
```

Example:

```bash
chmod 400 ~/my-aws-key.pem
```

---

## Configuration

Some values in the files are placeholders. Change them to match your own AWS environment **before** running the project.

| # | Setting | File | Default / Placeholder |
|---|---------|------|-----------------------|
| 1 | AWS region | `main.tf` | `ap-south-1` |
| 2 | Key pair name | `main.tf` | `your-key` |
| 3 | SSH private key path | `inventory.ini` | `#path_to_your_private_key_file` |
| 4 | SSH user | `inventory.ini` | `#your_user_name` |
| 5 | App repository | `playbook.yml` | `rat9615/simple-nodejs-app` |
| 6 | EC2 AMI | `main.tf` | `ami-01a00762f46d584a1` |
| 7 | Instance type | `main.tf` | `t2.micro` |

### 1. AWS Region

In `main.tf`:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

`ap-south-1` is the AWS Mumbai region. To use another region, replace it, for example:

```hcl
region = "us-east-1"
```

Make sure the AMI you use is available in the selected region.

### 2. AWS Key Pair

In `main.tf`:

```hcl
key_name = "your-key"
```

`your-key` is only a placeholder. Replace it with the name of an existing EC2 key pair in your AWS account:

```hcl
key_name = "my-aws-key"
```

The key pair must exist in the **same AWS region**.

> **Important:** Do not upload your `.pem` private key to GitHub.

### 3. SSH Private Key Path

In `inventory.ini`:

```ini
ansible_ssh_private_key_file=#path_to_your_private_key_file
```

Replace the placeholder with the path to your private key on your own computer:

```ini
ansible_ssh_private_key_file=/home/ubuntu/my-aws-key.pem
```

The exact path depends on where you saved your `.pem` file.

> **Important:** Do not paste the contents of the private key into `inventory.ini`. Only give the **path** to the key.

### 4. Ansible SSH User

In `inventory.ini`:

```ini
ansible_ssh_user=#your_user_name
```

This project uses Ubuntu, so the username should normally be:

```ini
ansible_ssh_user=ubuntu
```

### 5. Node.js Application Repository

`playbook.yml` currently contains:

```yaml
repo_url: "https://github.com/rat9615/simple-nodejs-app"
```

This is the application being deployed. To deploy a different Node.js app, replace the URL:

```yaml
repo_url: "https://github.com/YOUR_USERNAME/YOUR_NODE_APP"
```

If you want a different application directory, also update:

```yaml
app_dir: "/home/ubuntu/simple-nodejs-app"
```

### 6. EC2 AMI

In `main.tf`:

```hcl
ami = "ami-01a00762f46d584a1"
```

AMI IDs are **region-specific**. If you change the AWS region, replace this with an Ubuntu AMI available in that region. The AMI must be an Ubuntu image compatible with the assignment.

### 7. Instance Type

The assignment requires a `t2.micro` instance. In `main.tf`, use:

```hcl
instance_type = "t2.micro"
```

If your configuration contains `t3.micro`, change it to `t2.micro`.

### Inventory File

Before running Terraform, `inventory.ini` contains a placeholder:

```ini
[webservers]
#add_newly_created_instance

[webservers:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=/path/to/your-key.pem
```

Terraform automatically replaces the second line with the public IP of the new EC2 instance. After Terraform runs, it looks similar to:

```ini
[webservers]
13.234.XX.XX

[webservers:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/my-aws-key.pem
```

You do **not** need to enter the EC2 IP address manually.

---

## Deployment

**1. Initialize Terraform**

```bash
terraform init
```

**2. Validate the configuration**

```bash
terraform validate
```

**3. Review the planned infrastructure**

```bash
terraform plan
```

**4. Create the EC2 instance and deploy the application**

```bash
terraform apply
```

When Terraform asks for confirmation, type `yes`.

Terraform will then:

1. Create the security group
2. Create the EC2 instance
3. Get the EC2 public IP address
4. Add the public IP to `inventory.ini`
5. Run the Ansible playbook
6. Configure the Ubuntu server
7. Clone the Node.js application
8. Install dependencies
9. Start the application

---

## Access the Application

The security group allows port `3000`. After deployment, open:

```
http://YOUR_EC2_PUBLIC_IP:3000
```

Replace `YOUR_EC2_PUBLIC_IP` with the public IP of your EC2 instance.

---

## Destroy the Infrastructure

When you are finished, remove all AWS resources created by Terraform:

```bash
terraform destroy
```

Confirm with `yes`. This helps you avoid unnecessary AWS charges.

---

## Security Notes

**Never upload these to GitHub:**

- `*.pem`
- `*.key`
- `terraform.tfstate`
- `terraform.tfstate.*`
- AWS access keys and secret keys
- Private SSH keys
- Passwords
- API tokens
- Any other credentials

A recommended `.gitignore`:

```gitignore
*.pem
*.key
terraform.tfstate
terraform.tfstate.*
.terraform/
```

Values such as `your-key`, `/path/to/your-key.pem` and `YOUR_EC2_PUBLIC_IP` in this README are only **examples/placeholders**.

---

## Assignment Files

| File | Description |
|------|-------------|
| `main.tf` | Terraform infrastructure configuration |
| `playbook.yml` | Ansible deployment playbook |
| `inventory.ini` | Ansible inventory |
| `README.md` | Project documentation |
