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
                    // Use 'bat' for Windows command prompt commands.
                    bat "docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // This block securely uses the 'dockerhub-credentials' you stored in Jenkins.
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo "Logging in to Docker Hub and pushing image..."
                    // Use 'bat' and Windows-style %VAR% for environment variables.
                    bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
                    // The docker push command.
                    bat "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

       stage('Deploy to Kubernetes') {
            steps {
                // This block still correctly loads the secret file and provides its path in the KUBECONFIG variable.
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    script {
                        echo "Deploying new image to Kubernetes..."
                        
                        // THIS IS THE FIX: We explicitly tell kubectl where to find its config
                        // by using the --kubeconfig flag and passing the variable.
                        bat "kubectl --kubeconfig=%KUBECONFIG% set image deployment/fibonacci-app fibonacci-app=${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                        echo "Waiting for deployment to complete..."
                        // We do the same for the second command.
                        bat "kubectl --kubeconfig=%KUBECONFIG% rollout status deployment/fibonacci-app"
                    }
                }
            }
        }
    }

    post {
        always {
            // This stage runs no matter what, ensuring you always log out of Docker Hub.
            echo "Logging out of Docker Hub..."
            bat "docker logout"
        }
    }
}