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
                sshagent(['deploy-ec2-creds']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@jenkins-agent-1 << EOF
                            docker pull rahulreghunath/addressbook:v1
                            docker rm -f addressbook || true
                            docker run -d --name addressbook -p 8080:8080 rahuldocker314/addressbook:v1
                        EOF
                    '''
                }
            }
        }


    }
}
