# CI/CD Pipeline for a Fibonacci Calculator Web App

This project demonstrates a complete, end-to-end CI/CD pipeline for a simple Python Flask web application. The application is containerized with Docker, deployed to a local Kubernetes cluster (Minikube), and the entire build-and-deploy process is automated using Jenkins.

## ✨ Project Overview

The primary goal of this project is to automate the deployment workflow. Every time a developer pushes a code change to the `main` branch on GitHub, Jenkins will automatically:
1.  **Build** a new Docker image for the application.
2.  **Push** the image to a Docker Hub registry.
3.  **Deploy** the new image to the Kubernetes cluster, triggering a seamless rolling update.

### Core Technologies
*   **Application:** Python (Flask)
*   **Containerization:** Docker
*   **Orchestration:** Kubernetes (Minikube)
*   **CI/CD Automation:** Jenkins
*   **Version Control:** Git & GitHub

## 🚀 Getting Started: Step-by-Step Guide

Follow these instructions to set up and run the entire project on your local machine.

### Prerequisites

Before you begin, ensure you have the following software installed and configured on your Windows machine:

1.  **Git:** For version control.
2.  **Docker Desktop:** For containerizing the application. Make sure it is running.
3.  **Minikube:** To run a local Kubernetes cluster.
4.  **kubectl:** The Kubernetes command-line tool.
5.  **Jenkins:** Installed and running locally. You can run it via `java -jar jenkins.war` or as a service.
6.  **A GitHub Account:** To host the source code.
7.  **A Docker Hub Account:** To store the container images.
8.  **ngrok:** To expose your local Jenkins server to the internet for webhooks.

### Step 1: Local Project Setup

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-username/your-repository-name.git
    cd your-repository-name
    ```

2.  **Start Your Kubernetes Cluster:**
    ```powershell
    minikube start
    ```

### Step 2: Jenkins Configuration

#### A. Install Required Jenkins Plugins
1.  Navigate to **Manage Jenkins > Plugins**.
2.  Go to the **Available plugins** tab.
3.  Install the following:
    *   `Docker Pipeline`
    *   `Kubernetes CLI`
    *   `Git` (usually installed by default)

#### B. Configure Global Tools
Jenkins needs to know where your `git.exe` is located.
1.  Navigate to **Manage Jenkins > Tools**.
2.  In the **Git** section, click **Add Git**.
3.  **Name:** `Default`
4.  **Path to Git executable:** `C:\Program Files\Git\bin\git.exe`
5.  Click **Save**.

#### C. Add Required Credentials
We need to securely store passwords for Docker Hub and Kubernetes.

1.  **Docker Hub Credentials:**
    *   Go to **Manage Jenkins > Credentials > (global) > Add Credentials**.
    *   **Kind:** `Username with password`.
    *   **Username:** Your Docker Hub username.
    *   **Password:** Your Docker Hub password.
    *   **ID:** `dockerhub-credentials` (This must be an exact match).
    *   Click **Create**.

2.  **Kubernetes Config Credentials:**
    *   Find your Kubernetes config file, typically located at `C:\Users\YourUsername\.kube\config`.
    *   Go back to **Manage Jenkins > Credentials > (global) > Add Credentials**.
    *   **Kind:** `Secret file`.
    *   **File:** Click **Choose File** and upload the `config` file from the path above.
    *   **ID:** `kubeconfig` (This must be an exact match).
    *   Click **Create**.

#### D. Create the Jenkins Pipeline Job
1.  On the Jenkins dashboard, click **New Item**.
2.  Enter a name (e.g., `fibonacci-app-pipeline`), select **Pipeline**, and click **OK**.
3.  Scroll down to the **Pipeline** section.
4.  Change the **Definition** to **Pipeline script from SCM**.
5.  **SCM:** Select **Git**.
6.  **Repository URL:** Enter the HTTPS URL of your GitHub repository.
7.  **Branch Specifier:** Change `*/master` to `*/main`.
8.  Click **Save**.

### Step 3: GitHub Webhook Configuration

This step connects GitHub to your local Jenkins server.

1.  **Start `ngrok`:** Open a **new, separate terminal** and run the following commands to create a public URL for your Jenkins server.
    ```powershell
    # First, you need to authenticate ngrok (only do this once)
    # Get your token from https://dashboard.ngrok.com/get-started/your-authtoken
    ./ngrok config add-authtoken <YOUR_AUTHTOKEN>

    # Start the tunnel to your Jenkins server on port 8080
    ./ngrok http 8080
    ```

2.  **Copy the `ngrok` URL:** Copy the public "Forwarding" URL that `ngrok` provides (the one starting with `https://`).

3.  **Create the Webhook in GitHub:**
    *   In your GitHub repository, go to **Settings > Webhooks > Add webhook**.
    *   **Payload URL:** Paste your `ngrok` URL and add `/github-webhook/` at the end.
        *   Example: `https://your-random-string.ngrok-free.app/github-webhook/`
    *   **Content type:** `application/json`.
    *   Click **Add webhook**. You should see a green checkmark indicating a successful test delivery.

### Step 4: Manual First Deployment

Before the automation can take over, we need to create the initial deployment and service objects in Kubernetes.

1.  **Ensure your terminal is pointed at Minikube's Docker environment:**
    ```powershell
    minikube docker-env | Invoke-Expression
    ```
2.  **Build the initial Docker image:**
    ```powershell
    docker build -t your-dockerhub-username/fibonacci-app:latest .
    ```
3.  **Apply the Kubernetes manifests:**
    ```powershell
    kubectl apply -f kubernetes/deployment.yaml
    kubectl apply -f kubernetes/service.yaml
    ```
4.  **Verify the pod is running:**
    ```powershell
    kubectl get pods
    # Wait for the status to be "Running"
    ```

### Step 5: Trigger the CI/CD Pipeline!

You are all set! The next time you push a code change, the pipeline will run.

1.  **Make a change** to any file in the `app` directory.
2.  **Commit and push** the change to the `main` branch.
    ```bash
    git add .
    git commit -m "My first automated deployment!"
    git push origin main
    ```
3.  **Watch the magic:** Go to your Jenkins dashboard. A new build will start automatically, progress through all the stages, and deploy the new version of your application.

4.  **View Your Application:**
    ```powershell
    minikube service fibonacci-service
    ```
This command will open your live, running application in a web browser.
