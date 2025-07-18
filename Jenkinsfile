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
                        ssh -o StrictHostKeyChecking=no -i $KEY ubuntu@18.116.8.130 '
                            docker pull rahuldocker314/addressbook:v1 &&
                            docker rm -f addressbook || true &&
                            docker run -d --name addressbook -p 8080:8080 rahuldocker314/addressbook:v1
                        '
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    echo "🛠 Resetting kubeconfig and refreshing context..."
                    rm -rf ~/.kube/config
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER

                    echo "🔐 Fetching static token for EKS..."
                    TOKEN=$(aws eks get-token --region $AWS_REGION --cluster-name $EKS_CLUSTER --output text --query 'status.token')

                    echo "🔧 Creating token-based user and context..."
                    kubectl config set-credentials eks-token-user --token="$TOKEN"
                    CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}')
                    kubectl config set-context eks-token-context --cluster="$CLUSTER_NAME" --user=eks-token-user
                    kubectl config use-context eks-token-context

                    echo "🚀 Deploying manifests to EKS..."
                    kubectl apply -f k8s/deployment.yaml --validate=false
                    kubectl apply -f k8s/service.yaml --validate=false

                    echo "📦 Rollout and service check..."
                    kubectl rollout status deployment/addressbook
                    kubectl get svc addressbook-service
                '''
            }
        }
    }
}
