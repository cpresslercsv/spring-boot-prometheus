// library(
//   identifier: 'docker-image-pipeline-library'
// )
// sonarscanner()


DOCKER_MAVEN_IMAGE = 'maven:3-openjdk-11-slim'
DOCKER_MAVEN_ARGS = """\
-v $JENKINS_HOME/.m2:$JENKINS_HOME/.m2 \
-v $JENKINS_HOME/.config:$JENKINS_HOME/.config \
-v $JENKINS_HOME/.cache:$JENKINS_HOME/.cache \
"""

pipeline {
    environment {
        DEPLOY = "${env.BRANCH_NAME == "develop" ? "true" : "false"}"
        NAME = readMavenPom().getName()
        VERSION = readMavenPom().getVersion()
        SHORT_COMMIT = "${GIT_COMMIT[0..7]}"
        MAVEN_OPTS = "-Duser.home=/var/lib/jenkins"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = credentials('aws-region')
        INFINITY_JWKS_URL = credentials('infinity-jwks-url')
        CMK_ARN = credentials('cmk-arn')
        DB = credentials('customers-db')
        CLUSTER_NAME= credentials('cluster-name')
        RTP_SERVICE_USER = credentials('rtp-service-user')
        SALT = credentials('salt')
    }
    agent {
          docker {
            image DOCKER_MAVEN_IMAGE
            args DOCKER_MAVEN_ARGS
            reuseNode true
          }
    }
    stages {
        stage('Prepare') {
          steps {
            script {
              echo sh(script: 'env|sort', returnStdout: true)
            }
          }
        }
        stage('Checkout') {
          steps {
            checkout scm
          }
        }
        stage('Build') {
            agent {
                docker {
                    image DOCKER_MAVEN_IMAGE
                    args DOCKER_MAVEN_ARGS
                }
            }
            steps{
                sh 'mvn -B -U -DskipTests clean package'
            }
        }
        stage('Scan') {
          steps {
            // generate test and code coverage first
            sh "mvn  clean test"

            sh "mvn sonar:sonar -Dsonar.projectKey=${JOB_BASE_NAME} -Dsonar.host.url=https://sonarqube.softvisionvegas.com \
              -Dsonar.login=${SONARQUBE_TOKEN}"
          }
        }
    }
}
