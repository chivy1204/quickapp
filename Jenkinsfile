/* groovylint-disable CompileStatic, DuplicateStringLiteral, FileEndsWithoutNewline, GStringExpressionWithinString, LineLength, UnnecessaryGString */
pipeline {
    agent {
        node {
            label "master"
        }
    }
    parameters { 
        string(name: 'EnvironmentTarget', defaultValue: 'Test', description: 'Environment: Test, Production')
    }
    environment {
        NORMAL = params.EnvironmentTarget.toLowerCase();
        ENVIRONMEN_TARGET = "${params.EnvironmentTarget}";
        WORKSPACE = "${env.WORKSPACE}";
        BUILD_ID = "${env.BUILD_ID}";

        NEXUS_URL = "34.72.187.15:8081"
        CHANNEL_SLACK = "U021GTUANLT"
        TEAM_DOMAIN = "https://devops-aow1052.slack.com"
    }
    stages {
        stage('Build WebApi') {
            steps {
                sh '''
                    cd QuickApp
                    export ASPNETCORE_ENVIRONMENT=$ENVIRONMEN_TARGET
                    dotnet publish -c $ENVIRONMEN_TARGET
                '''
                zip dir: "QuickApp/bin/$ENVIRONMEN_TARGET/net5.0", exclude: '', glob: '', zipFile: "webapi.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'webapi', classifier: '', file: 'webapi.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official',
                    groupId: 'webapi',
                    nexusUrl: "$NEXUS_URL",
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: 'allure-official',
                    version: '$BUILD_ID'
                sh '''
                    pwd
                    rm webapi.zip
                    cd QuickApp/bin/
                    rm -r $ENVIRONMEN_TARGET
                '''
            }
        }
        stage('Build Frontend') {
            steps {
                sh "cd QuickApp/ClientApp && npm install && ng build --configuration=${NORMAL}"
                zip dir: "QuickApp/ClientApp/dist", exclude: '', glob: '', zipFile: "frontend.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'frontend', classifier: '', file: 'frontend.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official',
                    groupId: 'frontend',
                    nexusUrl: "$NEXUS_URL",
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
        stage("Sonar Scan") {
            steps {
                sh '''
                    dotnet sonarscanner begin /k:"ScanAPI" /d:sonar.host.url="https://34.66.191.23"  /d:sonar.login="f31193a30cacb3ea3887692fe2c9a5b7537b7a53"
                    dotnet build
                    dotnet sonarscanner end /d:sonar.login="f31193a30cacb3ea3887692fe2c9a5b7537b7a53"
                '''
            }
        }
        stage('Unit Test') {
            steps {
                warnError('Unstable Tests') {
                    sh "cd QuickApp.Tests && dotnet test --logger:trx"
                }
                script {
                    allure([
                                includeProperties: false,
                                jdk: '',
                                properties: [],
                                reportBuildPolicy: 'ALWAYS',
                                results: [[path: 'QuickApp.Tests/TestResults']]
                    ])
                }
                zip dir: "allure-report", exclude: '', glob: '', zipFile: "allure-report.zip"
                nexusArtifactUploader artifacts: [[
                    artifactId: 'allure-report', classifier: '', file: 'allure-report.zip', type: 'zip'
                    ]], credentialsId: 'nexus-google-official',
                    groupId: 'allure-report',
                    nexusUrl: "$NEXUS_URL",
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
        stage("Create Infra") {
            steps {
                sh '''
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }
        stage("Deploy WebApi") {
            steps {
                sshagent(credentials : ['terraform-agent']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -l vync $(terraform output --raw host) \
                        "sudo systemctl reload nginx && \
                        cd /home/vync/backend && \
                        sudo mkdir abc &&\
                        sudo rm -r /home/vync/backend/* && \
                        sudo curl -O http://${NEXUS_URL}/repository/allure-official/webapi/webapi/${BUILD_ID}/webapi-${BUILD_ID}.zip && \
                        sudo unzip webapi-100.zip && \
                        sudo systemctl enable quickapp.service && \
                        sudo systemctl start quickapp.service"
                    '''
                }
            }
        }
        // stage('Parallel Deploy') {
        //     environment {
        //         WEBPAPI = "webapi-quickapp-${NORMAL}"
        //         FRONTEND = "frontend-quickapp-${NORMAL}"
        //     }
        //     parallel {
        //         stage('Deploy report') {
        //             agent {
        //                 node {
        //                     label 'agent'
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                     cd /var/www/html
        //                     sudo rm -r /var/www/html/*
        //                     sudo curl -O http://${NEXUS_URL}/repository/allure-official/allure-report/allure-report/${BUILD_ID}/allure-report-${BUILD_ID}.zip
        //                     sudo unzip allure-report-${BUILD_ID}.zip
        //                     sudo rm allure-report-${BUILD_ID}.zip
        //                 '''
        //             }
        //         }
        //         stage('Deploy backend') {
        //             agent {
        //                 node {
        //                     label "$WEBPAPI"
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                     cd /home/vync/backend
        //                     sudo rm -r /home/vync/backend/*
        //                     sudo curl -O http://${NEXUS_URL}/repository/allure-official/webapi/webapi/${BUILD_ID}/webapi-${BUILD_ID}.zip
        //                     sudo unzip webapi-${BUILD_ID}.zip
        //                     sudo systemctl restart kestrel-quickapp
        //                 '''
        //             }
        //         }
        //         stage('Deploy frontend') {
        //             agent {
        //                 node {
        //                     label "$FRONTEND"
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                     cd /var/www/html
        //                     sudo rm -r /var/www/html/*
        //                     sudo curl -O http://${NEXUS_URL}/repository/allure-official/frontend/frontend/${BUILD_ID}/frontend-${BUILD_ID}.zip
        //                     sudo unzip frontend-${BUILD_ID}.zip
        //                     sudo rm frontend-${BUILD_ID}.zip
        //                 '''
        //             }
        //         }
        //     }
        // }
    }
    // post {
    //     success {
    //         slackSend botUser: true,
    //             channel: "$CHANNEL_SLACK",
    //             message: "CICD thành công trên môi trường $NORMAL ở version $BUILD_ID",
    //             teamDomain: "$TEAM_DOMAIN",
    //             tokenCredentialId: 'slack-token'
    //     }
    //     failure {
    //         slackSend botUser: true,
    //             channel: "$CHANNEL_SLACK",
    //             message: "CICD thất bại trên môi trường $NORMAL ở version $BUILD_ID",
    //             teamDomain: "$TEAM_DOMAIN",
    //             tokenCredentialId: 'slack-token'
    //     }
    //     aborted {
    //         slackSend botUser: true,
    //             channel: "$CHANNEL_SLACK",
    //             message: "CICD bị dừng đột ngột trên môi trường $NORMAL ở version $BUILD_ID",
    //             teamDomain: "$TEAM_DOMAIN",
    //             tokenCredentialId: 'slack-token'
    //     }
    //     unstable {
    //         slackSend botUser: true,
    //             channel: "$CHANNEL_SLACK",
    //             message: "Ứng dụng trên môi trường $NORMAL ở version $BUILD_ID không ổn định. Kiểm tra thông tin test report tại http://allurereportquickapp.eastus.cloudapp.azure.com",
    //             teamDomain: "$TEAM_DOMAIN",
    //             tokenCredentialId: 'slack-token'
    //     }
    // }
}