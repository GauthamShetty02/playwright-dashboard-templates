pipeline {
    agent any
    
    parameters {
        string(name: 'VPS_IP', defaultValue: '72.60.99.67', description: 'VPS IP Address')
        string(name: 'VPS_USER', defaultValue: 'root', description: 'VPS Username')
        string(name: 'DEPLOY_PATH', defaultValue: '/var/www/html/test-reports', description: 'Deployment Path on VPS')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy Templates to VPS') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'hostinger-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                        # Copy template and script to VPS
                        scp -i \$SSH_KEY -o StrictHostKeyChecking=no index-template.html ${params.VPS_USER}@${params.VPS_IP}:${params.DEPLOY_PATH}/
                        scp -i \$SSH_KEY -o StrictHostKeyChecking=no generate-index.sh ${params.VPS_USER}@${params.VPS_IP}:${params.DEPLOY_PATH}/
                        
                        # Make script executable
                        ssh -i \$SSH_KEY -o StrictHostKeyChecking=no ${params.VPS_USER}@${params.VPS_IP} "chmod +x ${params.DEPLOY_PATH}/generate-index.sh"
                    """
                }
            }
        }
    }
}