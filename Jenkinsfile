pipeline {
    agent { label 'build-node' }

    environment {
        IMAGE_NAME = 'rahuldocker314/addressbook'
        TAG = 'v1'
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
            script {
                def ec2_ip = sh(
                    script: """aws ec2 describe-instances \
                        --filters "Name=tag:Name,Values=JenkinsAgent2" \
                        --query "Reservations[*].Instances[*].PublicIpAddress" \
                        --output text""",
                    returnStdout: true
                ).trim()
    
                echo "Discovered IP: ${ec2_ip}"
    
                sshagent(['jenkins-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${ec2_ip} << 'EOF'
                            docker pull rahuldocker314/addressbook:v1
                            docker rm -f addressbook || true
                            docker run -d --name addressbook -p 8080:8080 rahuldocker314/addressbook:v1
                        EOF
                    """
                }
            }
        }
    }



    }
}
