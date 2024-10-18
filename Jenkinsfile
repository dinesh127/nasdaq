pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

   agent  any
    stages {
        stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                             checkout scmGit(branches: [[name: 'nasdaq']], 
                                userRemoteConfigs: [[url: 'https://github.com/dinesh127/nasdaq']])
                        }
                    }
                }
            }
         stage('setlocation') {
            steps {
                powershell 'Set-Location -Path "C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\test\\terraform"'
                  }
        }
 stage('Plan') {
            steps {
                powershell 'terraform.exe terraform init'
                powershell 'terraform plan -out=tfplan'
                powershell 'terraform show'
                  }
        }

        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
           }

           steps {
               script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            steps {
                sh "pwd;cd terraform/ ; terraform apply -input=false tfplan"
            }
        }
    }

  }
