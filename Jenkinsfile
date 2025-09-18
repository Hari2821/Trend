pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'hari2821/trend:latest'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/hari2821/Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -f dist/Dockerfile -t $DOCKER_IMAGE dist/'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-dev', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh '''
                    kubectl apply -f k8s/namespace.yaml
                    kubectl apply -f k8s/deployment.rendered.yaml
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }

    post {
        failure {
            echo '❌ Pipeline failed. Check the logs for more information.'
        }
        success {
            echo '✅ Application deployed successfully to Minikube!'
        }
    }
}

