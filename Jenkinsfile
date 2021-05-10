pipeline {
    agent any

    stages {
        stage('Check dotnet') {
            steps {
                sh 'dotnet --version'
            }
        }
        stage('Check npm') {
            steps {
                sh 'npm --version'
            }
        }
        stage('Build backend') {
            steps {
                sh '''
                cd QuickApp
                dotnet build
                '''
            }
        }
        stage('Build fronted') {
            steps {
                sh '''
                cd QuickApp/ClientApp
                ng build
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
    }
}