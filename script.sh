#!/bin/bash

# Проверка и установка зависимостей (curl и unzip)
function install_dependencies {
    echo "Checking dependencies..."
    if ! command -v curl &> /dev/null; then
        echo "curl not found. Installing..."
        sudo apt-get update && sudo apt-get install -y curl
    else
        echo "curl is already installed."
    fi

    if ! command -v unzip &> /dev/null; then
        echo "unzip not found. Installing..."
        sudo apt-get update && sudo apt-get install -y unzip
    else
        echo "unzip is already installed."
    fi
}

# Установка Terraform
function install_terraform {
    echo "Downloading Terraform..."
    curl -fsSL https://releases.hashicorp.com/terraform/$(curl -fsSL https://releases.hashicorp.com/terraform/ | grep -oP '\d+\.\d+\.\d+' | head -1)/terraform_$(curl -fsSL https://releases.hashicorp.com/terraform/ | grep -oP '\d+\.\d+\.\d+' | head -1)_linux_amd64.zip -o terraform.zip
    unzip terraform.zip
    sudo mv terraform /usr/local/bin/
    rm terraform.zip
    echo "Terraform installed successfully!"
}

# Проверка установки Terraform
function check_terraform {
    echo "Checking Terraform installation..."
    terraform -v
    if [ $? -ne 0 ]; then
        echo "Terraform is not installed. Installing..."
        install_terraform
    else
        echo "Terraform is already installed."
    fi
}

# Проверка конфигурации Terraform
function validate_terraform {
    echo "Validating Terraform configuration..."
    terraform init
    terraform validate
    if [ $? -eq 0 ]; then
        echo "Terraform configuration is valid."
    else
        echo "Terraform configuration has errors."
    fi
}

# Проверка установки kubectl
function check_kubectl {
    echo "Checking kubectl installation..."
    kubectl version --client
    if [ $? -ne 0 ]; then
        echo "kubectl is not installed. Please install kubectl manually."
        exit 1
    else
        echo "kubectl is already installed."
    fi
}

# Проверка манифеста Kubernetes
function validate_kubernetes_manifest {
    echo "Validating Kubernetes manifest..."
    kubectl apply --dry-run=client -f kubernetes/deployment.yaml
    if [ $? -eq 0 ]; then
        echo "Kubernetes manifest is valid."
    else
        echo "Kubernetes manifest has errors."
    fi
}

# Основной процесс
function main {
    echo "Starting project setup..."
    install_dependencies
    check_terraform
    cd terraform
    validate_terraform
    cd ..
    check_kubectl
    validate_kubernetes_manifest
    echo "Project setup complete."
}

main
