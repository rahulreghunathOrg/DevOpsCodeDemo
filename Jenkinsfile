stage('Deploy to EKS') {
    steps {
        sh '''
            echo "🔄 Updating kubeconfig for EKS..."
            aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER

            echo "🔐 Fetching token manually..."
            TOKEN=$(aws eks get-token --region $AWS_REGION --cluster-name $EKS_CLUSTER --output text --query 'status.token')

            echo "🧬 Creating static context with token..."
            kubectl config set-credentials eks-token-user --token="$TOKEN"
            kubectl config set-context eks-token-context \
              --cluster=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}') \
              --user=eks-token-user
            kubectl config use-context eks-token-context

            echo "🚀 Deploying to EKS..."
            kubectl apply -f k8s/deployment.yaml --validate=false
            kubectl apply -f k8s/service.yaml --validate=false

            echo "📦 Rollout status..."
            kubectl rollout status deployment/addressbook
            kubectl get svc addressbook-service
        '''
    }
}
