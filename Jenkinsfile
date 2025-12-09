pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "rnkbansal"
        DOCKER_IMAGE_NAME = "${DOCKERHUB_USERNAME}/fibonacci-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    // Use 'bat' for Windows command prompt
                    bat "docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo "Logging in to Docker Hub and pushing image..."
                    // Use 'bat' for Windows. Note the use of %VAR% for environment variables in batch.
                    bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
                    // Docker push command is the same.
                    bat "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // This 'withCredentials' block is the new part.
                // It finds the secret file with the ID 'kubeconfig' and creates an environment
                // variable named 'KUBECONFIG' that contains the path to that secret file.
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    script {
                        echo "Deploying new image to Kubernetes..."
                        
                        // Because the KUBECONFIG variable is now set, these kubectl commands
                        // will automatically find and use it for authentication.
                        bat "kubectl set image deployment/fibonacci-app fibonacci-app=${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                        echo "Waiting for deployment to complete..."
                        bat "kubectl rollout status deployment/fibonacci-app"
                    }
                }
            }
        }
    post {
        always {
            echo "Logging out of Docker Hub..."
            // Use 'bat' for Windows command prompt
            bat "docker logout"
        }
    }
}