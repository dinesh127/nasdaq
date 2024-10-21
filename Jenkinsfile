pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy the Terraform configuration')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
    }
    stages {
        stage('checkout') {
            steps {
                script {
                    dir('terraform') {
                        checkout scmGit(branches: [[name: 'Assignment']], userRemoteConfigs: [[url: 'https://github.com/dinesh127/nasdaq']])
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    echo 'Running terraform init'
                    sh "pwd;cd terraform/ ; terraform init"
                }
            }
        }
        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo 'Running terraform plan'
                    sh "pwd;cd terraform/ ; terraform plan -var "aws_access_key=$AWS_ACCESS_KEY_ID" -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" -out tfplan"
                }
            }
        }
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo 'Running terraform apply'
                    sh "pwd;cd terraform/ ; terraform apply -input=false tfplan"
                }
            }
        }
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo 'Running terraform destroy'
                    sh "pwd;cd terraform/ ; terraform destroy -var "aws_access_key=$AWS_ACCESS_KEY_ID" -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" -input=false tfplan"
                    }
            }
        }
    }
}
