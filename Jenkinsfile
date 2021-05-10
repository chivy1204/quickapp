pipeline {
    agent any

    stages {
        stage('Build backend') {
            steps {
                sh '''
                    cd QuickApp
                    dotnet publish -c Release
                '''
            }
        }
        stage('Build fronted') {
            steps {
                sh '''
                cd QuickApp/ClientApp
                ng build --prod
                '''
            }
        }
        stage('Test') {
            steps {
                warnError('Unstable Tests') {
                    sh "cd QuickApp.Tests && dotnet test --logger:trx"
                }

            }
        }
        stage('Report') {
            steps {
                script {
                    allure([
                                includeProperties: false,
                                jdk: '',
                                properties: [],
                                reportBuildPolicy: 'ALWAYS',
                                results: [[path: 'QuickApp.Tests/TestResults']]
                    ])
                }
            }
        }
        stage('Nexus upload') {
            steps{
                zip dir: "allure-report", exclude: '', glob: '', zipFile: "allure-report.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'allure-report', classifier: '', file: 'allure-report.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google', 
                    groupId: 'allure-report', 
                    nexusUrl: '35.222.128.49:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'allure-official',
                    version: '$BUILD_ID'
                sh 'pwd'
                sh "rm allure-report.zip"
            }
        }
        stage('Deploy report') {
            agent {
                node {
                    label 'agent'
                }
            }
            steps {
                
                sh '''
                    cd /var/www/html
                    sudo rm -r /var/www/html/*
                    sudo curl -O http://35.222.128.49:8081/repository/allure-official/allure-report/allure-report/${BUILD_ID}/allure-report-${BUILD_ID}.zip
                    sudo unzip allure-report-${BUILD_ID}.zip
                    sudo rm allure-report-${BUILD_ID}.zip
                '''
            }
        }
    }
}