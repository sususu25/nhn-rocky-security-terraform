pipeline {
    agent any

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Source Checkout'
            }
        }

        stage('Terraform Init') {
            steps {
                echo '🔧 Terraform Init'
                sh '''
                  terraform init -backend=false
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                echo '✅ Terraform Validate'
                sh '''
                  terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                echo '📄 Terraform Plan'
                sh '''
                  terraform plan -input=false
                '''
            }
        }

        stage('Shell Script Test') {
            steps {
                echo '🧪 Shell script execution'
                sh '''
                  echo "Running security scripts..."
                  ls -al
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline SUCCESS'
        }
        failure {
            echo '❌ Pipeline FAILED'
        }
        always {
            echo '🧹 Pipeline finished'
        }
    }
}
