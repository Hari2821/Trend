pipeline {
    agent any

    environment {
        IMAGE_NAME = "hari2821/trend"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/hari2821/Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME:latest
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh '''
                kubectl delete deployment trend-web -n trend --ignore-not-found
                kubectl apply -f k8s/namespace.yaml
                kubectl apply -f k8s/deployment.rendered.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }
}

