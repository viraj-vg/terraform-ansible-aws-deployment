Terraform + Ansible AWS Deployment
Assignment 2 — Terraform + Ansible Integration

This project demonstrates how to use Terraform and Ansible together to automatically deploy a Node.js application on an AWS EC2 instance.

Terraform creates the AWS infrastructure, including the EC2 instance and security group. After the instance is created, Terraform uses the local-exec provisioner to run the Ansible playbook automatically.

The final goal is:

terraform apply


This creates the server and automatically configures and deploys the Node.js application.

Technologies Used

AWS EC2

Terraform

Ansible

Ubuntu

Node.js

Git

SSH

Project Structure
terraform-ansible-aws-deployment/
│
├── main.tf
├── playbook.yml
├── inventory.ini
└── README.md

main.tf

Terraform configuration responsible for:

Creating an AWS security group

Allowing SSH traffic on port 22

Allowing application traffic on port 3000

Creating an Ubuntu EC2 instance

Automatically running the Ansible playbook

Passing the newly created EC2 public IP to Ansible

inventory.ini

Ansible inventory containing the newly created EC2 instance's public IP and SSH configuration.

playbook.yml

Ansible playbook that:

Waits for the EC2 instance to become available

Updates the Ubuntu package cache

Installs Git, curl and Node.js

Clones the Node.js application

Installs npm dependencies

Starts the Node.js application

Before Running the Project

There are a few values in the files that you must change for your own AWS environment.

1. AWS Region

In main.tf:

provider "aws" {
    region = "ap-south-1"
}


ap-south-1 is the AWS Mumbai region.

If you want to use another AWS region, replace it with your region.

For example:

region = "us-east-1"


Make sure the AMI you use is available in the selected region.

2. AWS Key Pair

In main.tf:

key_name = "your-key"


your-key is only a placeholder.

Replace it with the name of an existing EC2 key pair in your AWS account.

For example:

key_name = "my-aws-key"


The key pair must already exist in the same AWS region.

Do not upload your .pem private key to GitHub.

3. SSH Private Key Path

In inventory.ini:

ansible_ssh_private_key_file=#path_to_your_private_key_file


Replace the placeholder with the path to your private SSH key on your own computer.

For example:

ansible_ssh_private_key_file=/home/ubuntu/my-aws-key.pem


The exact path depends on where you saved your .pem file.

Do not put the actual private key contents inside inventory.ini.

Only specify the path to the key.

4. Ansible SSH User

In inventory.ini:

ansible_ssh_user=#your_user_name


Because this project uses Ubuntu, the SSH username should normally be:

ansible_ssh_user=ubuntu

5. Node.js Application Repository

The current playbook.yml contains:

repo_url: "https://github.com/rat9615/simple-nodejs-app"


This is the application repository being deployed.

If you want to deploy a different Node.js application, replace this URL.

For example:

repo_url: "https://github.com/YOUR_USERNAME/YOUR_NODE_APP"


Also update:

app_dir: "/home/ubuntu/simple-nodejs-app"


if you want to use a different application directory.

6. EC2 AMI

In main.tf:

ami = "ami-01a00762f46d584a1"


The AMI ID is region-specific.

If you change the AWS region, you may need to replace the AMI ID with an Ubuntu AMI available in that region.

Make sure the AMI is an Ubuntu image compatible with the assignment.

7. Instance Type
   
instance_type = "t3.micro"

if you need to follow the assignment specification exactly.

Required Software

Install the following on the Ubuntu machine from which Terraform and Ansible will be executed:

Terraform

Ansible

AWS CLI

Git

You also need:

An AWS account

An AWS EC2 key pair

The corresponding .pem private key

AWS credentials configured on your machine

Configure AWS Credentials

Configure your AWS credentials before running Terraform.

For example:

aws configure


Enter your:

AWS Access Key ID
AWS Secret Access Key
Default region
Output format


Do not put AWS access keys or secret keys inside main.tf or any GitHub file.

Set Up the SSH Key

Make sure your private key has the correct permissions:

chmod 400 /path/to/your-key.pem


For example:

chmod 400 ~/my-aws-key.pem


Then make sure inventory.ini points to the correct path:

ansible_ssh_private_key_file=/home/ubuntu/my-aws-key.pem

Configure inventory.ini

Before running Terraform, the inventory contains a placeholder:

[webservers]
#add_newly_created_instance

[webservers:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=/path/to/your-key.pem


Terraform automatically replaces the second line with the public IP address of the newly created EC2 instance.

After Terraform creates the instance, it will look similar to:

[webservers]
13.234.XX.XX

[webservers:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/my-aws-key.pem


You normally do not need to manually enter the EC2 IP address.

Deployment

Initialize Terraform:

terraform init


Check the Terraform configuration:

terraform validate


Review the planned infrastructure:

terraform plan


Create the EC2 instance and deploy the application:

terraform apply


When Terraform asks for confirmation, enter:

yes


Terraform will:

Create the security group.

Create the EC2 instance.

Obtain the EC2 public IP address.

Add the public IP to inventory.ini.

Run the Ansible playbook.

Configure the Ubuntu server.

Clone the Node.js application.

Install dependencies.

Start the application.

Access the Application

The security group allows port 3000.

After deployment, open:

http://YOUR_EC2_PUBLIC_IP:3000


Replace YOUR_EC2_PUBLIC_IP with the public IP address of your EC2 instance.

Destroy the Infrastructure

When you are finished, remove the AWS resources created by Terraform:

terraform destroy


Confirm with:

yes


This helps avoid unnecessary AWS charges.

Important Security Notes

Do not upload the following files or information to GitHub:

*.pem
*.key
terraform.tfstate
terraform.tfstate.*


Do not upload:

AWS access keys

AWS secret keys

Private SSH keys

Passwords

API tokens

Other credentials

The values such as:

your-key
/path/to/your-key.pem
YOUR_EC2_PUBLIC_IP


in this README are only examples/placeholders.

GitHub Upload

After checking the files, initialize Git:

git init


Add the project files:

git add main.tf playbook.yml inventory.ini README.md


Create a commit:

git commit -m "Add Terraform and Ansible deployment"


Connect your GitHub repository:

git remote add origin https://github.com/YOUR_USERNAME/terraform-ansible-aws-deployment.git


Push the project:

git branch -M main
git push -u origin main
