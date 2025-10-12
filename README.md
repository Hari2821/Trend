🚀 Trend App – Full DevOps CI/CD Deployment on AWS
Author: Hari
GitHub Repo: https://github.com/Hari2821/Trend.git
Deployed App: Kubernetes LoadBalancer on Port 80

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
FROM node:18-alpine
RUN apk add --no-cache bash curl && npm install -g serve
WORKDIR /app
COPY . .
EXPOSE 3000
CMD ["serve", "-s", ".", "-l", "3000"]
docker build -t trend-app .
docker run -p 3000:3000 trend-app
DockerHub Repo: hari2821/trend-app:latest


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
pipeline {
 agent any
 environment {
 DOCKER_USER = 'hari2821'
 IMAGE_NAME = 'trend-app'
 }
 stages {
 stage('Build Docker Image') {
 steps {
 dir('dist') {
 sh 'docker build -t ${IMAGE_NAME} .'
 }
 }
 }
 stage('Push to DockerHub') {
 steps {
 withCredentials([usernamePassword(...)]) {
 sh 'docker push ${DOCKER_USER}/${IMAGE_NAME}:latest'
 }
 }
 }
 stage('Deploy to EKS') {
 steps {
 sh 'kubectl apply -f dist/k8/*.yaml'
 }
 }
 }
}

☸️ 5. Kubernetes Configuration

dist/k8/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trend-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trend
  template:
    metadata:
      labels:
        app: trend
    spec:
      containers:
      - name: trend
        image: hari2821/trend-app:latest
        ports:
        - containerPort: 3000
dist/k8/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: trend-service
spec:
  type: LoadBalancer
  selector:
    app: trend
  ports:
    - port: 80
      targetPort: 3000

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
