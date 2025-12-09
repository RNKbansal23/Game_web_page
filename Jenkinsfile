pipeline {
    agent any // This means Jenkins can use any available agent/node to run this pipeline.

    environment {
        // Sets a variable for your Docker Hub username. Change this if it's different.
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
                    // Builds the Docker image.
                    // The tag is the Jenkins BUILD_NUMBER (e.g., 1, 2, 3...), ensuring a unique tag for every build.
                    echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // This block securely uses the credentials you will store in Jenkins.
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo "Logging in to Docker Hub and pushing image..."
                    // Log in to Docker Hub using the stored credentials.
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    // Push the newly built and tagged image.
                    sh "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying new image to Kubernetes..."
                    // This is the most efficient way to update a running deployment.
                    // It tells Kubernetes to find the 'fibonacci-app' deployment and set the image for the container
                    // named 'fibonacci-app' to the new version we just pushed.
                    // Kubernetes will then automatically perform a rolling update.
                    sh "kubectl set image deployment/fibonacci-app fibonacci-app=${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                    echo "Waiting for deployment to complete..."
                    // This command waits for the rolling update to finish successfully.
                    sh "kubectl rollout status deployment/fibonacci-app"
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