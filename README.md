🚀 Trend App – Full DevOps CI/CD Deployment on AWS
Author: Hari
GitHub Repo: https://github.com/Hari2821/Trend.git
Deployed App: [Kubernetes LoadBalancer on Port 80]
(http://a6abb43a3ea0e47bab9ede041547c874-2091392275.us-east-1.elb.amazonaws.com/)

🧩 Project Overview
This project demonstrates a production-ready DevOps pipeline that automates the entire
application lifecycle — from code commit to deployment on AWS EKS, with real-time monitoring
using open-source tools.
Key Stack: Terraform, Docker, AWS EKS, Jenkins, GitHub Webhooks, Prometheus + Grafana

📦 1. Application Setup
git clone https://github.com/Vennilavan12/Trend.git
cd Trend
React app runs on Port 3000. Exposed via Kubernetes LoadBalancer (Port 80).

🐳 2. Dockerization
Check the Dockerfile

☁️ 3. Terraform Infrastructure Setup
Provisions: VPC, Subnets, Security Groups, IAM Roles, EC2 (Jenkins), EKS Cluster + Node Group
cd terraform
terraform init
terraform apply -auto-approve

⚙️ 4. Jenkins CI/CD Pipeline
Plugins: Docker, Docker Pipeline, GitHub Integration, Kubernetes CLI, Pipeline
GitHub Webhook: http://:8080/github-webhook/
docker login -u $DOCKER_USER --password-stdin

💡 Jenkinsfile (/dist/Jenkinsfile)
check Jenkinsfile

☸️ 5. Kubernetes Configuration

dist/k8/deployment.yaml
Check the dist/k8/deployment.yaml file
dist/k8/service.yaml
check the dist/k8/service.yaml file

📊 6. Monitoring Setup
Prometheus: http://:9090
Node Exporter: http://:9100/metrics
Grafana: http://:3000 — Login: admin/admin

🌐 8. Final Deliverables
GitHub Repo, Terraform Infra, Docker Image, Jenkins Pipeline, GitHub Webhook, EKS
Deployment, Monitoring, Screenshots

✅ Conclusion
This project demonstrates a complete DevOps CI/CD pipeline using Terraform, Jenkins, Docker,
AWS EKS, and open-source monitoring tools.
webhook Sun Nov  2 05:43:28 PST 2025
webhook Sun Nov  2 05:45:32 PST 2025
webhook Sun Nov  2 05:55:51 PST 2025
webhook Sun Nov  2 05:56:52 PST 2025
