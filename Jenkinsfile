pipeline {
    agent any // This means Jenkins can use any available agent/node to run this pipeline.

    environment {
        // Sets a variable for your Docker Hub username.
        DOCKERHUB_USERNAME = "rnkbansal"
        // The name of the image you will build and push.
        DOCKER_IMAGE_NAME = "${DOCKERHUB_USERNAME}/fibonacci-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // This command checks out the code from the GitHub repository that triggered the build.
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    // Use 'sh' for Linux shell commands.
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // This block securely uses the 'dockerhub-credentials' you stored in Jenkins.
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo "Logging in to Docker Hub and pushing image..."
                    // Use 'sh' and Linux-style $VAR for environment variables.
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    // The docker push command.
                    sh "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // This block securely loads your Kubernetes config file.
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    script {
                        echo "Deploying new image to Kubernetes..."
                        
                        // FIX ADDED HERE: --insecure-skip-tls-verify=true
                        // This forces kubectl to trust the certificate even though the IP address changed to host.docker.internal
                        sh "kubectl --insecure-skip-tls-verify=true --kubeconfig=$KUBECONFIG set image deployment/fibonacci-app fibonacci-app=${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                        echo "Waiting for deployment to complete..."
                        // FIX ADDED HERE: --insecure-skip-tls-verify=true
                        sh "kubectl --insecure-skip-tls-verify=true --kubeconfig=$KUBECONFIG rollout status deployment/fibonacci-app"
                    }
                }
            }
        }
    }

    post {
        always {
            // This stage runs no matter what, ensuring you always log out of Docker Hub.
            echo "Logging out of Docker Hub..."
            sh "docker logout"
        }
    }
}