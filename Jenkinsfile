pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        aws_access_key = credentials('aws_access_key')
        aws_secret_key = credentials('aws_secret_key')
    }

   agent  any
    stages {
        stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                             checkout scmGit(branches: [[name: 'Assignment']], 
                                userRemoteConfigs: [[url: 'https://github.com/dinesh127/nasdaq']])
                        }
                    }
                }
            }
stage('Plan') {
            steps {
                sh "pwd;cd terraform/ ; terraform init"
                sh "pwd;cd terraform/ ; terraform plan -var "aws_access_key=$aws_access_key" -var "aws_secret_key=$aws_secret_key" -out=tfplan"
                sh "pwd;cd terraform/ ; terraform show -no-color tfplan > tfplan.txt"
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
