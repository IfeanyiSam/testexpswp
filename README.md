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

## Infrastructure Components

1. **VPC**: Creates a Virtual Private Cloud to isolate the infrastructure within its own network.
2. **Public Subnets**: Two public subnets are created in different Availability Zones (`us-east-1a` and `us-east-1b`).
3. **Internet Gateway**: Allows the VPC to communicate with the internet.
4. **Route Table**: Configures the routing of traffic between the VPC and the internet via the Internet Gateway.
5. **Security Group**: Configures firewall rules to allow traffic on ports 80 (HTTP) and 3000 (application port).
6. **Key Pair**: Automatically generates an SSH key pair for secure access to EC2 instances.
7. **EC2 Instances**: Launches two EC2 instances in the public subnets with a user data script for initialization.
8. **Application Load Balancer (ALB)**: Distributes incoming traffic across the EC2 instances.
9. **Target Group**: Manages the instances registered with the ALB.
10. **Health Check**: Ensures that the ALB routes traffic only to healthy instances by checking the `/api/greeting` endpoint.

## Important Files

- **Dockerfile**: Defines the environment and dependencies for the Node.js application.
- **docker-compose.yml**: Manages the container lifecycle.
- **main.tf**: Terraform configuration file defining the AWS resources.
- **userdata.sh**: Script to install Docker and Docker Compose on the EC2 instances, clones the repository, builds the app image and starts the container

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

## Configuration

### VPC Configuration

- **CIDR Block**: `10.0.0.0/16`

### Subnets

- **Public Subnet 1 (us-east-1a)**: `10.0.1.0/24`
- **Public Subnet 2 (us-east-1b)**: `10.0.2.0/24`

### Security Group

- Allows inbound traffic on ports 80 and 3000.
- Allows all outbound traffic.

### EC2 Instances

- **AMI**: `ami-0e86e20dae9224db8`
- **Instance Type**: `t2.micro`
- **Tags**:
  - `app_server1`
  - `app_server2`

### Load Balancer

- **Name**: `app_lb`
- Listens on port 80 and forwards traffic to the target group on port 3000.

### Health Check

- **Path**: `/api/greeting`
- **Protocol**: `HTTP`
- **Port**: `traffic-port`
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy Threshold**: 3
- **Unhealthy Threshold**: 2

## Files

- **`main.tf`**: The main Terraform configuration file defining the AWS resources.
- **`userdata.sh`**: User data script executed on instance startup. (Ensure this file is present in the same directory as `main.tf`)

## Notes

- Ensure the `userdata.sh` script is correctly configured for your application needs.
- Adjust the AMI ID in the script if necessary to match the appropriate region and instance type.

## Contributing

If you have suggestions or improvements, please submit a pull request or create an issue.
