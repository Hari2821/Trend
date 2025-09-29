terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "trans-array-286720"
  region  = "us-west1"
  zone    = "us-west1-b"
}

# ---------------------------
# VPC & Subnet
# ---------------------------
resource "google_compute_network" "vpc" {
  name                    = "jenkins-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "jenkins-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc.id
}

# ---------------------------
# Firewall Rules
# ---------------------------
resource "google_compute_firewall" "allow_traffic" {
  name    = "jenkins-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# ---------------------------
# Service Account
# ---------------------------
resource "google_service_account" "jenkins_sa" {
  account_id   = "jenkins-sa"
  display_name = "Jenkins Service Account"
}

resource "google_project_iam_member" "sa_role" {
  project = "trans-array-286720"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

# ---------------------------
# Compute Engine (VM)
# ---------------------------
resource "google_compute_instance" "jenkins" {
  name         = "jenkins-server"
  machine_type = "e2-medium"
  zone         = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250924"
      size  = 30
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  service_account {
    email  = google_service_account.jenkins_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    echo "📦 Updating system packages..."
    sudo apt update -y
    sudo apt upgrade -y

    # ---------------------------
    # Install Docker (official repo)
    # ---------------------------
    echo "🐳 Installing Docker..."
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $$(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$${VERSION_CODENAME}}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo groupadd docker || true
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker

    # ---------------------------
    # Install Jenkins (WAR service)
    # ---------------------------
    echo "☕ Installing Java 17..."
    sudo apt install -y openjdk-17-jdk wget

    echo "📁 Creating Jenkins directory..."
    sudo mkdir -p /opt/jenkins
    sudo chown ubuntu:ubuntu /opt/jenkins
    cd /opt/jenkins

    echo "⬇️ Downloading Jenkins WAR..."
    wget -q https://get.jenkins.io/war-stable/2.452.2/jenkins.war

    echo "🛠 Creating Jenkins systemd service..."
    sudo tee /etc/systemd/system/jenkins.service > /dev/null <<EOF
[Unit]
Description=Jenkins WAR Service (manual)
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/jenkins
ExecStart=/usr/bin/java -jar /opt/jenkins/jenkins.war
SuccessExitStatus=143
TimeoutStopSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    echo "🔄 Reloading systemd & starting Jenkins..."
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
  EOT
}

# ---------------------------
# Outputs
# ---------------------------
output "jenkins_public_ip" {
  value = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
}

output "jenkins_url" {
  value = "http://${google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip}:8080"
}

output "ssh_command" {
  value = "ssh ubuntu@${google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip}"
}

