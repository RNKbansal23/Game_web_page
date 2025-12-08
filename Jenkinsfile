pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE_NAME = "your-dockerhub-username/fibonacci-app"
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building the Docker image...'
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }
        stage('Login') {
            steps {
                script {
                    echo 'Logging in to Docker Hub...'
                    sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    echo 'Pushing the Docker image...'
                    sh "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    sh "kubectl set image deployment/fibonacci-app fibonacci-app=${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }
    }
}