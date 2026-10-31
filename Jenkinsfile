pipeline {
    agent any

    environment {
        // GitHub Repository
        GIT_REPO_URL             = 'https://github.com/bus57790/oracle-dbops.git'
        GIT_CREDENTIALS_ID       = 'github-credentials' // Jenkins Credential ID for GitHub access
        
        // Docker Hub Credentials & Repository
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKERHUB_REPO           = 'bus57790/oracle-dbops'
        IMAGE_TAG                = "${BUILD_NUMBER}"
        
        // Target Host & SonarQube Configurations
        TARGET_DB_HOST           = '192.168.1.184'
        SONAR_HOST_URL           = 'http://192.168.1.184:9000'
        SONAR_CREDENTIALS_ID     = 'sonarqube-token'
        
        // Slack Webhook Configuration (loaded securely via credentials or env)
        SLACK_WEBHOOK_URL        = credentials('slack-webhook-url')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: env.GIT_CREDENTIALS_ID, url: env.GIT_REPO_URL
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withCredentials([string(credentialsId: env.SONAR_CREDENTIALS_ID, variable: 'SONAR_TOKEN')]) {
                        sh """
                            docker run --rm \
                              -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
                              -e SONAR_TOKEN="${SONAR_TOKEN}" \
                              -v "\$(pwd):/usr/src" \
                              sonarsource/sonar-scanner-cli
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} -t ${DOCKERHUB_REPO}:latest -f docker/Dockerfile .
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                            docker push ${DOCKERHUB_REPO}:latest
                        """
                    }
                }
            }
        }

        stage('Commit & Push Manifests to GitHub') {
            steps {
                script {
                    withCredentials([gitUsernamePassword(credentialsId: env.GIT_CREDENTIALS_ID, gitToolName: 'git-tool')]) {
                        sh """
                            # 1. Update image tag in the Kubernetes Job manifest
                            sed -i 's|image: .*|image: ${DOCKERHUB_REPO}:${IMAGE_TAG}|g' manifests/db-operation-job.yaml

                            # 2. Configure Git identity
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@192.168.1.184"

                            # 3. Stage, commit, and push updated manifests back to GitHub
                            git add manifests/
                            git commit -m "ci: update db-operation-job image tag to ${IMAGE_TAG} [skip ci]" || echo "No changes to commit"
                            git push origin HEAD:main
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            sh """
                curl -X POST -H 'Content-type: application/json' \
                  --data '{"text":":white_check_mark: *Jenkins Pipeline Succeeded!*\\n*Image:* `${DOCKERHUB_REPO}:${IMAGE_TAG}` pushed to Docker Hub.\\n*GitHub:* Updated manifests pushed to `bus57790/oracle-dbops`. ArgoCD sync triggered on `192.168.1.184`."}' \
                  ${SLACK_WEBHOOK_URL}
            """
        }
        failure {
            sh """
                curl -X POST -H 'Content-type: application/json' \
                  --data '{"text":":x: *Jenkins Pipeline Failed!*\\n*Build Number:* ${BUILD_NUMBER}\\nCheck Jenkins console logs for details."}' \
                  ${SLACK_WEBHOOK_URL}
            """
        }
    }
}
