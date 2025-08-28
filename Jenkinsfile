pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'ashok948'
        IMAGE_TAG = "${env.BRANCH_NAME}"   // dev, prod, etc.
        EC2_HOST = 'root@43.205.255.0'     // root login
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKERHUB_USER}/${IMAGE_TAG}:latest .
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                 usernameVariable: 'DOCKERHUB_USER',
                                                 passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh """
                        echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
                        docker push ${DOCKERHUB_USER}/${IMAGE_TAG}:latest
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ssh login-aws']) {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                     usernameVariable: 'DOCKERHUB_USER',
                                                     passwordVariable: 'DOCKERHUB_PASS')]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${EC2_HOST} '
                                echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin &&
                                docker pull ${DOCKERHUB_USER}/${IMAGE_TAG}:latest &&
                                (docker stop ${IMAGE_TAG}-app || true) &&
                                (docker rm ${IMAGE_TAG}-app || true) &&
                                docker run -d -p 80:80 --name ${IMAGE_TAG}-app ${DOCKERHUB_USER}/${IMAGE_TAG}:latest
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
