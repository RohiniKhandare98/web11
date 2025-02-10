pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rohini1/web_new"
        SONAR_HOST_URL = 'http://localhost:9000'
	   SCANNER_HOME=tool 'sonar-scanner'        
   }

    stages {
    
        stage('SCM Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/RohiniKhandare98/web11.git'
            }
        }

stage('SonarQube Analysis') {
            steps {
                    withSonarQubeEnv('sonar-server') {
                        sh """
                               ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=p1 \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.login=sqp_3a5ec1b898b5061aec3e29cfb581fc6b21ae85ef
                        """
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
    

stage('Deploy to Kubernetes') {
    steps {
        script {
            withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "kubectl apply -f httpd-deployment.yaml"
            }
        }
    }
}
}

}
