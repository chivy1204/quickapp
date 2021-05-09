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
        stage('Check npm') {
            steps {
                sh '''
                npm --version
                '''
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
    }
}