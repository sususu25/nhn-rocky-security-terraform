pipeline {
  agent any

  parameters {
    choice(name: 'MODE', choices: ['plan', 'apply'], description: 'plan만 할지, apply까지 할지')
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init') {
      steps { sh 'terraform init -input=false' }
    }

    stage('Terraform Validate') {
      steps { sh 'terraform validate' }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS')]) {
          sh '''
            set -e
            terraform plan -input=false -var-file="$TFVARS" -out=tfplan
          '''
        }
      }
    }

    stage('Terraform Apply') {
      when { expression { return params.MODE == 'apply' } }
      steps {
        input message: "apply 진행할까?", ok: "APPLY"
        sh '''
          set -e
          terraform apply -input=false -auto-approve tfplan
          echo "applied" > apply_done.txt
        '''
      }
    }

    stage('Export Outputs') {
      steps {
        // apply를 안 했으면 output이 비어있을 수 있지만, 일단 파일은 남겨두자
        sh '''
          set +e
          terraform output -json > tf_output.json
          echo "tf_output.json generated"
        '''
      }
    }

    stage('Generate Inventory (apply only)') {
      when { expression { return params.MODE == 'apply' } }
      steps {
        sh '''
          set -e
          python3 scripts/tf_inventory.py > inventory.json
          echo "inventory.json generated"
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'tfplan,tf_output.json,inventory.json,apply_done.txt', allowEmptyArchive: true
    }
  }
}