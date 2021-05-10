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
        stage('Sonar scan'){
            steps{
                sh '''
                    export DOTNET_ROOT="/root/.dotnet"
                    cd QuickApp
                    dotnet sonarscanner begin /k:"backend-scan" /d:sonar.host.url="http://34.66.191.23"  /d:sonar.login="fba4a51f5db32f6eafd1fc582141b0651cba42ac"
                    dotnet build
                    dotnet sonarscanner end /d:sonar.login="fba4a51f5db32f6eafd1fc582141b0651cba42ac"
                '''
            }
        }
    }
}