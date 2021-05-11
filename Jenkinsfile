/* groovylint-disable CompileStatic, DuplicateStringLiteral, FileEndsWithoutNewline, GStringExpressionWithinString, LineLength, UnnecessaryGString */
pipeline {
    environment {
        WORKSPACE = "${env.WORKSPACE}";
        BUILD_ID = "${env.BUILD_ID}";
    }
    agent {
        node {
            label "master"
        }
    }
    parameters { 
        string(name: 'EnvironmentTarget', defaultValue: 'Production', description: 'Environment: Development, Test, Production')
    }
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
                    export ASPNETCORE_ENVIRONMENT=$EnvironmentTarget
                    echo $ASPNETCORE_ENVIRONMENT
                    dotnet publish -c $EnvironmentTarget
                '''
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
        stage('Nexus upload report') {
            agent {
                node {
                    label "master"
                }
            }
            steps {
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
                sh '''
                    pwd
                    rm allure-report.zip
                    rm -r allure-report
                    cd QuickApp.Tests
                    rm -r TestResults
                '''
            }
        }
        stage('Upload webAPI artifact') {
            agent {
                node {
                    label "master"
                }
            }
            steps {
                zip dir: "QuickApp/bin/$EnvironmentTarget/net5.0", exclude: '', glob: '', zipFile: "webapi.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'webapi', classifier: '', file: 'webapi.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official',
                    groupId: 'webapi',
                    nexusUrl: '34.72.187.15:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'allure-official',
                    version: '$BUILD_ID'
                sh '''
                    pwd
                    rm webapi.zip
                    cd QuickApp/bin/
                    rm -r $EnvironmentTarget
                '''
            }
        }
        stage('Upload Frontend artifact') {
            agent {
                node {
                    label "master"
                }
            }
            steps {
                zip dir: "QuickApp/ClientApp/dist", exclude: '', glob: '', zipFile: "frontend.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'frontend', classifier: '', file: 'frontend.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official',
                    groupId: 'frontend',
                    nexusUrl: '34.72.187.15:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'allure-official',
                    version: '$BUILD_ID'
                sh '''
                    pwd
                    rm frontend.zip
                    cd QuickApp/ClientApp
                    rm -r dist
                '''
            }
        }
        stage('Parallel Deploy') {
            when {
                expression {
                    "$EnvironmentTarget" == "Test"
                }
            }
            parallel {
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
                stage('Deploy backend') {
                    agent {
                        node {
                            label 'webapi-quickapp-test'
                        }
                    }
                    steps {
                        sh '''
                            cd /home/vync/backend
                            sudo rm -r /home/vync/backend/*
                            curl -O http://34.72.187.15:8081/repository/allure-official/webapi/webapi/${BUILD_ID}/webapi-${BUILD_ID}.zip
                            sudo unzip webapi-${BUILD_ID}.zip
                        '''
                    }
                }
                stage('Deploy frontend') {
                    agent {
                        node {
                            label 'frontend-quickapp-test'
                        }
                    }
                    steps {
                        sh '''
                            cd /var/www/html
                            sudo rm -r /var/www/html/*
                            sudo curl -O http://34.72.187.15:8081/repository/allure-official/frontend/frontend/${BUILD_ID}/frontend-${BUILD_ID}.zip
                            sudo unzip frontend-${BUILD_ID}.zip
                            sudo rm frontend-${BUILD_ID}.zip
                        '''
                    }
                }
            }
        }
        stage('Deploy QuickApp Production') {
            when {
                expression {
                    "$EnvironmentTarget" == "Production"
                }
            }
            agent {
                node {
                    label "quickapp-production"
                }
            }
            steps {
                sh '''
                    cd /var/www/html
                    sudo rm -r /var/www/html/*
                    sudo curl -O http://34.72.187.15:8081/repository/allure-official/frontend/frontend/${BUILD_ID}/frontend-${BUILD_ID}.zip
                    sudo unzip frontend-${BUILD_ID}.zip
                    sudo rm frontend-${BUILD_ID}.zip
                '''
            }

        }
        stage('Send slack') {
            steps {
                slackSend botUser: true,
                channel: 'U021GTUANLT',
                message: 'Deploy completed: Check report test at http://allurereportquickapp.eastus.cloudapp.azure.com and view frontend at https://frontendquickapptest.eastus.cloudapp.azure.com',
                teamDomain: 'https://devops-aow1052.slack.com',
                tokenCredentialId: 'slack-token'
            }
        }
    }
}