pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Git checkout'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Build step'
                sh 'echo Hello Jenkins'
            }
        }

        stage('Done') {
            steps {
                echo '✅ Pipeline finished'
            }
        }
    }
}
