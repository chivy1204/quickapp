pipeline {
    agent any

    stages {
        stage('Build backend') {
            agent {
                node {
                    label "master"
                }
            }
            steps {
                sh '''
                    cd QuickApp
                    dotnet publish -c Release
                '''
            }
        }
        stage('Upload webAPI artifact') {
            steps{
                zip dir: "QuickApp/QuickApp/bin/Release/net5.0", exclude: '', glob: '', zipFile: "webapi.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'webapi', classifier: '', file: 'webapi.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official', 
                    groupId: 'webapi', 
                    nexusUrl: '34.72.187.15:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'allure-official',
                    version: '$BUILD_ID'
                sh 'pwd'
                sh "rm webapi.zip"
            }
        }
        stage('Build frontend') {
            agent {
                node {
                    label "master"
                }
            }
            steps {
                sh '''
                cd QuickApp/ClientApp
                ng build --prod
                '''
            }
        }
        stage('Upload Frontend artifact') {
            steps{
                zip dir: "QuickApp/QuickApp/ClientApp/dist", exclude: '', glob: '', zipFile: "frontend.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'frontend', classifier: '', file: 'frontend.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official', 
                    groupId: 'frontend', 
                    nexusUrl: '34.72.187.15:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'allure-official',
                    version: '$BUILD_ID'
                sh 'pwd'
                sh "rm frontend.zip"
            }
        }
        stage('Test') {
            agent {
                node {
                    label "master"
                }
            }
            steps {
                warnError('Unstable Tests') {
                    sh "cd QuickApp.Tests && dotnet test --logger:trx"
                }

            }
        }
        stage('Report') {
            agent {
                node {
                    label "master"
                }
            }
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
            agent {
                node {
                    label "master"
                }
            }
            steps{
                zip dir: "allure-report", exclude: '', glob: '', zipFile: "allure-report.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'allure-report', classifier: '', file: 'allure-report.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official', 
                    groupId: 'allure-report', 
                    nexusUrl: '34.72.187.15:8081', 
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
                    sudo curl -O http://34.72.187.15:8081/repository/allure-official/allure-report/allure-report/${BUILD_ID}/allure-report-${BUILD_ID}.zip
                    sudo unzip allure-report-${BUILD_ID}.zip
                    sudo rm allure-report-${BUILD_ID}.zip
                '''
            }
        }
    }
}