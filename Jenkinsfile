pipeline {
    agent {
        kubernetes {
            cloud 'Kubernetes'  // Name of your Kubernetes cloud in Jenkins
//           yamlFile 'p2pod-template.yaml'  // Defines the Jenkins agent pod
        }
    }
  
     environment {
        DOCKER_IMAGE = "rohini1/web_new"
	   SCANNER_HOME=tool 'sonar-scanner'
	KUBECONFIG = credentials('jenkins-k8s-token')	
     GIT_REPO = 'git@github.com:https://github.com/RohiniKhandare98/web11.git'
        GIT_BRANCH = 'main'
        SSH_CRED_ID = 'k8-master'
    }
    stages {

        stage('SCM') {
            steps {
		git branch: 'main', credentialsId: 'git', url: 'https://github.com/RohiniKhandare98/web11.git'
            }
        }
        
        // stage("Sonarqube Analysis "){
        //  steps{   
        //     script {
        //      def scannerHome = tool name: 'sonar-scanner', type: 'ToolInstallation'
           
        //         withSonarQubeEnv('sonar-server') {
        //             //sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=web_app -Dsonar.projectKey=web_app
        //         sh '''   
        //             ${scannerHome}/bin/sonar-scanner \ 
        //             -Dsonar.projectKey=web_app \
        //             -Dsonar.sources=. \
        //             -Dsonar.host.url=http://192.168.80.167:9000 \
        //             -Dsonar.login=sqp_d51608d022e2a637f750a557998f700b644c70b8
        //             '''
        //         }
            
        //     }
        //  }    
        // }


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
/*        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            } 
        }
*/
/*	stage('TRIVY SCAN') {
            steps {
                sh "trivy $DOCKER_IMAGE"
            }
        }
*/


        stage('Build Docker Image') {
            steps {
                sh "/usr/bin/docker image build -t ${DOCKER_IMAGE}:latest ."
//sh 'echo "sunbeam" | sudo -S docker image build -t rohini1/web_new:latest .'
  
          }
        }


stage('TRIVY SCAN') {
            steps {
                 sh "trivy fs . > trivyfs.txt"
                   
            }
        }


        stage("Push Docker Image") {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_HUB_TOKEN', variable: 'DOCKER_HUB_TOKEN')]) {
                    sh "echo $DOCKER_HUB_TOKEN | /usr/bin/docker login -u rohini1 --password-stdin"
                    sh "/usr/bin/docker image push ${DOCKER_IMAGE}"
                }
            }
        }

 stage("TRIVY"){
            steps{
                sh "trivy image ${DOCKER_IMAGE} > trivyimage.txt" 
            }
        }
stage('OWASP FS SCAN') {
           steps {
               dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
               dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
           }
       }

   /*     stage("Deploy Docker Service") {
            steps {
		sh 'docker container rm --force backend'
                sh 'docker run -d --name backend -p 4000:80 ${DOCKER_IMAGE}'
		}
        }
        
*/

    stage('Copy Files from K8s Server') {
            steps {
                sshagent(['jenkins-ssh-key']) {
                    sh 'scp -r sunbeam@192.168.80.168:/home/sunbeam/p2 home/sunbeam/var/lib/jenkins/workspace/'
                }
            }
        }
        stage('Push to Git') {
            steps {
                dir('workspace') {
                    sh '''
                    git init
                    git remote add origin $GIT_REPO
                    git checkout -b $GIT_BRANCH || git checkout $GIT_BRANCH
                    git add .
                    git commit -m "Updated files from K8s server"
                    git push origin $GIT_BRANCH
                    '''
                }
            }
        }
	stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f httpd-deployment.yaml'  // Deploy the app
            }
        }
    }
}
