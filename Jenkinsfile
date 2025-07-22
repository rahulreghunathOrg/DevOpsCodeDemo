pipeline {
    agent { label 'agent1' }

    environment {
        IMAGE_NAME   = 'rahuldocker314/addressbook'
        TAG          = 'v1'
        AWS_REGION   = 'us-east-2'
        EKS_CLUSTER  = 'rahul-eks-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/rahulreghunathOrg/DevOpsCodeDemo.git'
            }
        }

        stage('Build WAR with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Run Unit Tests') {
            steps {
                // Executes tests and stores results as XML
                sh 'mvn test'
                
                // Publishes JUnit test results to Jenkins UI
                junit '**/target/surefire-reports/*.xml'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${TAG} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}:${TAG}"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ec2-key', keyFileVariable: 'KEY')]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i $KEY ubuntu@18.191.44.52 '
                            docker pull rahuldocker314/addressbook:v1 &&
                            docker rm -f addressbook || true &&
                            docker run -d --name addressbook -p 8080:8080 rahuldocker314/addressbook:v1
                        '
                    '''
                }
            }
        }

        stage('Debug Workspace') {
            steps {
                sh 'pwd && ls -la k8s/'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    echo "Resetting kubeconfig..."
                    rm -rf ~/.kube/config

                    echo "Setting kubeconfig from AWS CLI..."
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER

                    echo "Applying Kubernetes manifests..."
                    kubectl apply -f k8s/deployment.yaml --validate=false
                    kubectl apply -f k8s/service.yaml --validate=false

                    echo "Checking rollout and service..."
                    kubectl rollout status deployment/addressbook
                    kubectl get svc addressbook-service
                '''
            }
        }
    }
}
