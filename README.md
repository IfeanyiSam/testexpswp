# Terraform Project: Deploying a Dockerized Node.js Application on AWS

## Overview
This project demonstrates deploying a Node.js application on AWS using Terraform. The infrastructure includes a VPC with public subnets, EC2 instances running Dockerized containers, and an Application Load Balancer (ALB) to route traffic. The Node.js application is containerized with Docker, and Docker Compose is used to manage the container lifecycle.

## Architecture
- **VPC** with two public subnets.
- **EC2 Instances** running Ubuntu, provisioned with Docker and Docker Compose.
- **Application Load Balancer** (ALB) distributing traffic to the EC2 instances.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed.
- An AWS account configured with access keys.
- Basic knowledge of Terraform and Docker.

## Important Files

- **Dockerfile**: Defines the environment and dependencies for the Node.js application.
- **docker-compose.yml**: Manages the container lifecycle.
- **main.tf**: Terraform configuration file defining the AWS resources.
- **userdata.sh**: Script to install Docker and Docker Compose on the EC2 instances, clones the repository, builds the app image and starts the app container

## Usage

1. ## Clone the Repository:

   ```bash
   git clone https://github.com/IfeanyiSam/testexpswp.git 

   cd testexpswp/node-app 

2. ## Initialization and Management

### Initialize Terraform

Run `terraform init` to initialize the Terraform working directory and download necessary provider plugins.

```bash
terraform init
```

## Plan the Infrastructure

Run `terraform plan` to see the execution plan. This step shows what changes Terraform will make to achieve the desired state.

```bash
terraform plan
```
## Apply the Configuration

Run `terraform apply` to create the infrastructure as defined in the Terraform configuration. Confirm the apply action when prompted.

```bash
terraform apply
```
## Verify the Infrastructure

After the apply completes, Terraform will output the DNS name of the ALB and the public IP addresses of the EC2 instances. You can access the application through the ALB's DNS name at `http://<alb_dns_name>/api/greeting`.

## Destroy the Infrastructure (Optional)

If you want to tear down the infrastructure, run `terraform destroy`. Confirm the destroy action when prompted.

```bash
terraform destroy
```

# Setup Details

#### 1. VPC and Subnet Configuration
- A VPC was created with a CIDR block of `10.0.0.0/16`.
- Two public subnets were created in different Availability Zones:
  - **Subnet 1 (AZ: us-east-1a):** CIDR block `10.0.1.0/24`.
  - **Subnet 2 (AZ: us-east-1b):** CIDR block `10.0.2.0/24`.
- An Internet Gateway (IGW) was attached to allow communication from the internet to the instances.
- A route table was set up with a route to forward all traffic (`0.0.0.0/0`) to the IGW.
- The subnets were associated with the route table to ensure they had internet access.

#### 2. Security Group Configuration
- A security group was created to:
  - Allow inbound HTTP traffic on port `80` (for the ALB).
  - Allow inbound traffic on port `3000` (for the application running on EC2).
  - Allow all outbound traffic.

#### 3. EC2 Instance Configuration
- Two EC2 instances were launched with the following configurations:
  - **AMI:** `ami-0e86e20dae9224db8` (Ubuntu-based).
  - **Instance Type:** `t2.micro`.
  - **Key Pair:** Auto-generated using Terraform.
- Both instances were placed in separate subnets for redundancy:
  - **Instance 1:** Subnet 1 (us-east-1a).
  - **Instance 2:** Subnet 2 (us-east-1b).
- A user data script (`userdata.sh`) was used to install Docker and Docker Compose on both instances.

#### 4. Application Load Balancer (ALB) Setup
- An ALB was configured to:
  - Listen on port `80` and forward traffic to a target group listening on port `3000`.
  - The target group was associated with both EC2 instances.
  - Health checks were set up using the path `/api/greeting`, with HTTP as the protocol.

### Automation Explanation (Terraform)

#### Overview
Terraform was used to define and automate the following infrastructure components:

- **VPC and Networking:** The VPC, subnets, Internet Gateway, and route tables were defined to create a custom network.
- **EC2 Instances:** Instances were launched using an Ubuntu AMI, with a user data script for Docker installation.
- **Security Groups:** Configured to control traffic flow to the instances and ALB.
- **ALB and Target Groups:** Set up to distribute traffic across the EC2 instances.


## Notes

- Ensure the `userdata.sh` script is correctly configured for your application needs.
- Adjust the AMI ID in the script if necessary to match the appropriate region and instance type.

## Contributing

If you have suggestions or improvements, please submit a pull request or create an issue.
