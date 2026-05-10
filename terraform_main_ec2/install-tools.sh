#!/bin/bash

# Setup logging
LOG_FILE="/var/log/install-tools.log"
exec > >(tee -i $LOG_FILE) 2>&1

echo "---------------------------------------------------"
echo "🚀 Starting Infrastructure Tools Installation"
echo "Time: $(date)"
echo "---------------------------------------------------"

# Update system packages
sudo yum update -y

# Install essential tools (using --allowerasing to resolve curl-minimal conflicts)
sudo yum install -y git wget unzip curl yum-utils --allowerasing

# Install Java (required for Jenkins)
sudo dnf install -y java-21-amazon-corretto

# Install npm
sudo dnf install nodejs -y


# (Jenkins will be started at the end of the script to ensure all tools are in PATH)

# Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
terraform -v

# Install Maven
sudo yum install -y maven
mvn -v

# Install ansible
sudo yum install -y ansible
ansible --version

# Install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
kubectl version --client

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/
eksctl version

# Install Helm
wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
tar -zxvf helm-v3.6.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm
rm -rf helm-v3.6.0-linux-amd64.tar.gz linux-amd64
helm version

# Install Docker
sudo yum install -y docker
sudo usermod -aG docker ec2-user
sudo systemctl enable docker
sudo systemctl start docker
sudo chmod 777 /var/run/docker.sock
sudo docker --version  

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose --version

# Run SonarQube using Docker
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
sudo docker ps

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
trivy --version

# Install vault
sudo yum install -y vault




# Install MariaDB
sudo yum install -y mariadb105-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
mysql --version 
#systemctl status mariadb


# Install PostgreSQL 
sudo yum install -y postgresql15 postgresql15-server
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql
psql --version

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

echo "---------------------------------------------------"
echo "✅ Initialization script completed successfully."
echo "---------------------------------------------------"
echo "🛠️ Tool Versions Summary:"
echo "---------------------------------------------------"
git --version
java -version 2>&1 | head -n 1
node -v
npm -v
terraform -v
mvn -v
ansible --version | head -n 1
kubectl version --client
eksctl version
helm version --short
docker --version
docker-compose --version
trivy --version
vault version
mysql --version
psql --version
echo "---------------------------------------------------"
echo "Log file available at: $LOG_FILE"
echo "---------------------------------------------------"

# Start Jenkins now that all tools are installed
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins --allowerasing
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Add Jenkins to Docker group (now that it exists)
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "✅ Initialization script completed successfully."
