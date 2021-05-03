def defineEnvironment() {
    //String ACTUAL_BRANCH_NAME = "${env.BRANCH_NAME}"
    String ACTUAL_BRANCH_NAME = "develop"
    String PREFIX_BRANCH = ""
    String PREFIX_BRANCH_S3 = ""
    String ENVIRONMENT = ""
    String ORIGIN = "pexto"
    String NAME_COMPONENT_JENKINS = "${env.JOB_NAME.split("/")[0]}"

    switch(ACTUAL_BRANCH_NAME) {
      case "develop":
        PREFIX_BRANCH = "dev"
        PREFIX_BRANCH_S3 = "dev"
        ENVIRONMENT = "develop"
        break
      case ["master"]:
        PREFIX_BRANCH = "prod"
        PREFIX_BRANCH_S3 = ""
        ENVIRONMENT = "production"
        break
      default:
        PREFIX_BRANCH = "dev"
        PREFIX_BRANCH_S3 = "dev"
        ENVIRONMENT = "develop"
        break
    }

    return [
        ACTUAL_BRANCH_NAME,
        PREFIX_BRANCH,
        PREFIX_BRANCH_S3,
        ORIGIN,
        NAME_COMPONENT_JENKINS,
        ENVIRONMENT
    ]
}

pipeline {
    agent any

    environment {
        ACTUAL_BRANCH_NAME = defineEnvironment().get(0)
        PREFIX_BRANCH = defineEnvironment().get(1)
        PREFIX_BRANCH_S3 = defineEnvironment().get(2)
        ORIGIN = defineEnvironment().get(3)
        NAME_COMPONENT_JENKINS = defineEnvironment().get(4)
        ENVIRONMENT = defineEnvironment().get(5)
    }

    stages {

        stage('Notify start in slack') {
            environment {
                COMMIT_INFO = sh (script: 'git --no-pager show -s --format=\'%aN in commit "%s"\'', returnStdout: true).trim()
            }
            steps {
                script {
                    slackFirstMessage = slackSend(channel: "#jenkins-$PREFIX_BRANCH",
                          message: "${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Started compilation (<${BUILD_URL}|Open>)\n📣 Compilation #$BUILD_ID Started by ${COMMIT_INFO}")
                }
            }
        }

        stage("Install") {
            steps {
                sh "npm install"
            }
        }

        stage("Build") {
            steps {
                sh "npm run build-$ORIGIN-$PREFIX_BRANCH"
            }
        }

//         stage("SonarQube analysis") {
//             steps {
//                 sh "docker run --platform linux/amd64 --rm -v /Users/felipeardila1010/.m2:/root/.m2 -v $WORKSPACE:/app -w /app \
//                     maven:3-alpine mvn sonar:sonar \
//                         -Dsonar.projectKey=$NAME_COMPONENT_JENKINS \
//                         -Dsonar.host.url=http://sonarqube.qa.cobre.co \
//                         -Dsonar.login=d3f4b3583131da7da2430ea151ba73ae9b109821 \
//                         -Dsonar.java.binaries=./src"
//             }
//         }

        stage("Deploy") {
            steps {
                sh "echaasdo Deploy"
                // sh "aws s3 rm s3://jenkins-test7/${ORIGIN} --recursive"
                // sh "aws s3 cp www s3://jenkins-test7/${ORIGIN} --recursive --acl public-read"
            }
        }
    }

   post {
       always
       {
           sh "echo Finish Pipeline"
       }
       failure
       {
               addEmoji('alert')
               slackSend channel: "#jenkins-${PREFIX_BRANCH}",
                         color: 'danger',
                         message: "${NAME_COMPONENT_JENKINS} » ${env.customBranch} #${BUILD_ID} - #${BUILD_ID} Failed compilation\n❌ Compilation #${BUILD_ID}"
               responseSlackError()
       }
       success
       {
               slackSend channel: "#jenkins-${PREFIX_BRANCH}",
                         color: 'good',
                         message: "${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Finish compilation\n✔ Compilation #${BUILD_ID} with image tag `1.0.0`\n"
       }
       aborted {
          addEmoji('black_square_for_stop')
          responseFirstMessageAbort()
       }
   }
}


