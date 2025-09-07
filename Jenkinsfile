pipeline {
    agent any
    
    parameters {
        string(name: 'VPS_IP', defaultValue: '72.60.99.67', description: 'VPS IP Address')
        string(name: 'VPS_USER', defaultValue: 'root', description: 'VPS Username')
        string(name: 'DEPLOY_PATH', defaultValue: '/var/www/html/test-reports', description: 'Deployment Path on VPS')
    }
    
    tools {
        nodejs 'NodeJS'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy Node.js Project to VPS') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'hostinger-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                        # Create directory and copy project to VPS
                        ssh -i \$SSH_KEY -o StrictHostKeyChecking=no ${params.VPS_USER}@${params.VPS_IP} "mkdir -p ${params.DEPLOY_PATH}/dashboard-generator"
                        scp -i \$SSH_KEY -o StrictHostKeyChecking=no -r . ${params.VPS_USER}@${params.VPS_IP}:${params.DEPLOY_PATH}/dashboard-generator/
                        
                        # Install dependencies and make scripts executable
                        ssh -i \$SSH_KEY -o StrictHostKeyChecking=no ${params.VPS_USER}@${params.VPS_IP} "
                            cd ${params.DEPLOY_PATH}/dashboard-generator
                            npm install
                            chmod +x src/generate-index.js src/generate-multi-project.js
                            chmod +x generate-index.sh generate-multi-project-index.sh
                        "
                    """
                }
            }
        }
    }
}