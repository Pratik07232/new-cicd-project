pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        DOCKER_IMAGE = "pratik78124/my-cicd-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
        CONTAINER_NAME = "my-cicd-app"
    }

    stages {

        stage('Checkout') {
            steps {
                echo '==> Getting source code from GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '==> Building Docker image...'

                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Test') {
            steps {
                echo '==> Testing Docker container...'

                sh '''
                    docker run -d \
                        --name ${CONTAINER_NAME}-test \
                        -p 5001:5000 \
                        ${DOCKER_IMAGE}:${DOCKER_TAG}

                    sleep 5

                    curl -f http://localhost:5001/

                    docker stop ${CONTAINER_NAME}-test
                    docker rm ${CONTAINER_NAME}-test
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo '==> Pushing Docker image to DockerHub...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                echo '==> Deploying application...'

                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p 5000:5000 \
                        ${DOCKER_IMAGE}:latest

                    sleep 5

                    curl -f http://localhost:5000/
                '''
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD Pipeline completed successfully!'
        }

        failure {
            echo '❌ Pipeline failed. Check the logs.'
        }

        always {
            sh 'docker logout || true'
        }
    }
}