pipeline {
  agent any

  parameters {
    booleanParam(name: 'APPLY', defaultValue: false, description: 'true면 terraform apply 진행(변경 있을 때만)')
  }

  environment {
    ANSIBLE_USER = 'rocky'
    TF_HAS_CHANGES = 'false'
  }

  stages {
    stage('Checkout (Terraform repo)') {
      steps { checkout scm }
    }

    stage('Checkout (Ansible repo)') {
      steps {
        dir('ansible') {
          git url: 'https://github.com/sususu25/rocky-ansible-security.git', branch: 'main'
          sh 'ls -la'
        }
      }
    }

    stage('Precheck: Ansible role path') {
      steps {
        sh '''
          set -e
          test -d "ansible/playbooks/roles/security_script" || (echo "❌ role not found" && exit 1)
          test -f "ansible/playbooks/security_check.yml" || (echo "❌ playbook not found" && exit 1)
          echo "✅ Ansible structure OK"
        '''
      }
    }

    stage('Terraform Init') {
      steps { sh 'terraform init -input=false' }
    }

    stage('Terraform Validate') {
      steps { sh 'terraform validate' }
    }

    stage('Terraform Plan (detect changes)') {
      steps {
        withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS')]) {
          script {
            def rc = sh(
              script: 'terraform plan -input=false -var-file="$TFVARS" -detailed-exitcode -out=tfplan',
              returnStatus: true
            )
            if (rc == 0) {
              env.TF_HAS_CHANGES = 'false'
              echo "✅ No changes."
            } else if (rc == 2) {
              env.TF_HAS_CHANGES = 'true'
              echo "🟡 Changes detected."
            } else {
              error("❌ terraform plan failed (exit=${rc})")
            }
          }
        }
      }
    }

    stage('Terraform Apply') {
      when { expression { return params.APPLY && env.TF_HAS_CHANGES == 'true' } }
      steps {
        input message: "변경 감지됨. apply 진행?", ok: "APPLY"
        sh 'terraform apply -input=false -auto-approve tfplan'
      }
    }

    stage('Export TF Outputs -> Inventory') {
      steps {
        sh '''
          terraform output -json > tf_output.json
          python3 scripts/tf_inventory.py > inventory.json
          ansible-inventory -i inventory.json --list > /dev/null
          echo "✅ inventory.json generated"
        '''
      }
    }

    stage('Ansible Ping') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'bastion-ssh-key', keyFileVariable: 'SSH_KEY')]) {
          sh '''
            set -e
            export ANSIBLE_PRIVATE_KEY_FILE="$SSH_KEY"
            ansible -i inventory.json rocky_servers -m ping
          '''
        }
      }
    }

    stage('Ansible Run (security_check)') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'bastion-ssh-key', keyFileVariable: 'SSH_KEY')]) {
          sh '''
            set -e
            export ANSIBLE_PRIVATE_KEY_FILE="$SSH_KEY"
            export ANSIBLE_CONFIG="$PWD/ansible/ansible.cfg"

            # ✅ fetched_logs가 ansible 폴더 아래에 떨어지게 실행 위치를 ansible로 고정
            cd ansible
            ansible-playbook -i ../inventory.json playbooks/security_check.yml
          '''
        }
      }
    }
  }

  post {
    always {
      echo "🧹 Pipeline finished"
      archiveArtifacts artifacts: 'tf_output.json,inventory.json,tfplan', fingerprint: true, allowEmptyArchive: true
      archiveArtifacts artifacts: 'ansible/fetched_logs/**', fingerprint: false, allowEmptyArchive: true
    }
    failure {
      echo "❌ Pipeline FAILED"
    }
  }
}