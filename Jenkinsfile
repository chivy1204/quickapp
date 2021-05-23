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
        ENVIRONMENT_TARGET = "${params.EnvironmentTarget}";
        WORKSPACE = "${env.WORKSPACE}";
        BUILD_ID = "${env.BUILD_ID}";
        ENVIRONMENT_FILE = "environment.${NORMAL}.ts"
        NEXUS_URL = "34.72.187.15:8081"
        CHANNEL_SLACK = "U021GTUANLT"
        TEAM_DOMAIN = "https://devops-aow1052.slack.com"
    }
    stages {
        stage('Build WebApi') {
            steps {
                sh '''
                    cd QuickApp
                    export ASPNETCORE_ENVIRONMENT=$ENVIRONMENT_TARGET
                    dotnet publish -c $ENVIRONMENT_TARGET
                '''
                zip dir: "QuickApp/bin/$ENVIRONMENT_TARGET/net5.0", exclude: '', glob: '', zipFile: "webapi.zip"
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
                    rm -r $ENVIRONMENT_TARGET
                '''
            }
        }
        stage('Build WebApp') {
            steps {
                sh '''
                    cd QuickApp/ClientApp/src/environments
                    sed -i '' "s/example.com.vn/$(cat /tmp/quickappdns)/g" $ENVIRONMENT_FILE
                '''
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
                    cd QuickApp
                    dotnet sonarscanner begin /k:"ScanAPI" /d:sonar.host.url="http://34.66.191.23"  /d:sonar.login="f31193a30cacb3ea3887692fe2c9a5b7537b7a53"
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
        stage ("Deploy") {
            steps {
                sshagent(credentials : ['terraform-agent']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -l packer $(cat /tmp/quickappip) \
                        "sudo systemctl reload nginx && \
                        cd /home/packer/backend && \
                        sudo mkdir abc &&\
                        sudo rm -r /home/packer/backend/* && \
                        sudo curl -O http://${NEXUS_URL}/repository/allure-official/webapi/webapi/${BUILD_ID}/webapi-${BUILD_ID}.zip && \
                        sudo unzip webapi-${BUILD_ID}.zip && \
                        cd /var/www/html &&\
                        sudo rm -r /var/www/html/* &&\
                        sudo curl -O http://${NEXUS_URL}/repository/allure-official/frontend/frontend/${BUILD_ID}/frontend-${BUILD_ID}.zip &&\
                        sudo unzip frontend-${BUILD_ID}.zip &&\
                        sudo rm frontend-${BUILD_ID}.zip &&\
                        sudo systemctl restart quickapp.service"
                    '''
                }
            }
        }        
    }
}