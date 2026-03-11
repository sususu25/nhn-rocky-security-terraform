pipeline {
  agent any

  parameters {
    choice(
      name: 'MODE',
      choices: ['plan', 'apply', 'destroy'],
      description: 'Terraform execution mode: plan(계획), apply(적용), destroy(삭제)'
    )

    booleanParam(
      name: 'DESTROY_CONFIRM',
      defaultValue: false,
      description: 'MODE=destroy일 때 true로 설정해야 destroy 실행'
    )

    choice(
      name: 'ROCKY_COUNT',
      choices: [
        '1','2','3','4','5','6','7','8','9','10',
        '11','12','13','14','15','16','17','18','19','20',
        '21','22','23','24','25','26','27','28','29','30'
      ],
      description: 'Rocky 인스턴스 개수 (1~30)'
    )

    choice(
      name: 'VIP_MODE',
      choices: ['auto', 'manual'],
      description: 'LB VIP: auto(자동할당) / manual(수동입력)'
    )

    string(
      name: 'LB_VIP',
      defaultValue: '10.0.2.62',
      description: 'VIP_MODE=manual일 때 사용할 LB VIP (예: 10.0.2.62)'
    )
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate Params') {
      steps {
        script {
          if (params.VIP_MODE == 'manual' && !params.LB_VIP?.trim()) {
            error("VIP_MODE=manual 인데 LB_VIP 값이 비어있습니다.")
          }
        }
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init -input=false'
      }
    }

    stage('Terraform Validate') {
      when {
        expression { params.MODE == 'plan' || params.MODE == 'apply' }
      }
      steps {
        sh 'terraform validate'
      }
    }

    stage('Terraform Plan') {
      when {
        expression { params.MODE == 'plan' || params.MODE == 'apply' }
      }
      steps {
        withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS')]) {
          script {
            def lbVipValue = (params.VIP_MODE == 'manual') ? params.LB_VIP.trim() : ''

            sh """
              set -e
              terraform plan -input=false \\
                -var-file="\$TFVARS" \\
                -var="rocky_count=${params.ROCKY_COUNT}" \\
                -var="lb_vip_address=${lbVipValue}" \\
                -out=tfplan
              echo "tfplan generated"
            """
          }
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.MODE == 'apply' }
      }
      steps {
        input message: 'terraform apply 진행할까요?', ok: 'APPLY'
        sh '''
          set -e
          terraform apply -input=false -auto-approve tfplan
          echo "applied" > apply_done.txt
        '''
      }
    }

    stage('Export Outputs') {
      when {
        expression { params.MODE == 'apply' }
      }
      steps {
        sh '''
          set +e
          terraform output -json > tf_output.json
          echo "tf_output.json generated"
        '''
      }
    }

    stage('Terraform Destroy') {
      when {
        allOf {
          expression { params.MODE == 'destroy' }
          expression { params.DESTROY_CONFIRM == true }
        }
      }
      steps {
        input message: 'terraform destroy 진행할까요? (DESTROY_CONFIRM=true로 설정되어야 함)', ok: 'DESTROY'
        withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS')]) {
          script {
            def lbVipValue = (params.VIP_MODE == 'manual') ? params.LB_VIP.trim() : ''

            sh """
              set -e
              terraform destroy -input=false -auto-approve \\
                -var-file="\$TFVARS" \\
                -var="rocky_count=${params.ROCKY_COUNT}" \\
                -var="lb_vip_address=${lbVipValue}"
              echo "destroyed" > destroy_done.txt
            """
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'tfplan,tf_output.json,apply_done.txt,destroy_done.txt', allowEmptyArchive: true
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