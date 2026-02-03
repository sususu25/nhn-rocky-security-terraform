pipeline {
    agent any

    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS')]) {
                    sh '''
                      terraform plan \
                        -input=false \
                        -var-file=$TFVARS
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Pipeline finished'
        }
        success {
            echo '✅ Pipeline SUCCESS'
        }
        failure {
            echo '❌ Pipeline FAILED'
        }
    }
}
