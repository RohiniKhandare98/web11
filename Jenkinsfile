pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rohini1/web_new"
        SONAR_HOST_URL = 'http://localhost:9000'
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
    }

    stages {
    
        stage('SCM Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/RohiniKhandare98/web11.git'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_AUTH_TOKEN = credentials('sonar-token')
            }
            steps {
                script {
                    sh '''
                    /opt/sonar-scanner/bin/sonar-scanner \
                    -Dsonar.projectKey=sample_project \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Security Scan - Trivy') {
            steps {
                script {
                    sh '''
                    trivy image ${DOCKER_IMAGE} || echo "Security scan completed with warnings"
                    '''
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_HUB_TOKEN', variable: 'DOCKER_HUB_TOKEN')]) {
                    script {
                        sh '''
                        echo $DOCKER_HUB_TOKEN | docker login -u rohini1 --password-stdin
                        docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }
    }
}
