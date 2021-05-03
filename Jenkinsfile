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

// Define methods
def addEmoji(emoji) {
    if (slackFirstMessage != null) {
        slackFirstMessage.addReaction(emoji)
    }
}

def responseFirstMessageAbort() {
    if (slackFirstMessage != null) {
        slackSend(channel: slackFirstMessage.threadId,
                        color: 'warning',
                        message: "Compilation #${BUILD_ID} Aborted \n${sh(script:'wget --auth-no-challenge --user=smolina --password=1195c3d78f17d23dce759ac1fbe37497cb -O - $BUILD_URL/consoleText | grep \'Aborted by\'', returnStdout: true).substring(27)}")
    }
}
def responseSlackError() {
    if (slackFirstMessage != null) {
        slackSend(channel: slackFirstMessage.threadId, message: "*LOGS*\nErrors found in log:\n```${sh(script:'wget --auth-no-challenge --user=smolina --password=1195c3d78f17d23dce759ac1fbe37497cb -O - $BUILD_URL/consoleText | grep \'ERROR:\\|error\\|Error\\|\\[ERROR\\]\'', returnStdout: true)}```")
    }
}

// Run Steps of the Pipeline
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

    parameters {
        checkboxParameter(name:'Emisores', valueNodePath: '//CheckboxParameter/value', displayNodePath: '//CheckboxParameter/text', description: 'Emisores para desplegar', format:'JSON', uri:'https://cobre-utils.s3.us-east-2.amazonaws.com/pipeline/emisores.json')
    }

    stages {

        stage('Preparation') {
            steps {
                script {
                    env.MESSAGE_ERROR = ''
                    if ( params.Emisores == '' && env.ACTUAL_BRANCH_NAME.equals('prod')) {
                        env.MESSAGE_ERROR = '\nNo se ha seleccionado ningun Emisor para el deploy del pipeline de producción'
                        error(env.MESSAGE_ERROR)
                    }
                    if ( params.CustomBranchForDeploy != '' && env.AMBIENTE.equals('dev')) {
                        sh (script: 'git reset --hard')
                        sh (script: "git checkout ${params.CustomBranchForDeploy}")
                        sh (script: 'git pull')
                        env.BRANCH_NAME = params.CustomBranchForDeploy
                        defineEnvironment() // update pom in custom branch
                    } else {
                    }
                }
            }
        }

        stage('Slack started') {
            environment {
                COMMIT_INFO = sh (script: 'git --no-pager show -s --format=\'%aN in commit "%s"\'', returnStdout: true).trim()
            }
            steps {
                script {
                    slackFirstMessage = slackSend(channel: "#jenkins-$PREFIX_BRANCH",
                          message: "FE :iphone::vibration_mode: - ${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Started compilation (<${BUILD_URL}|Open>)\n📣 Compilation #$BUILD_ID Started by ${COMMIT_INFO}")
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
              sh "echo hola"
            }

            script {
              def LIST_EMISORES = []
              if ( params.Emisores != '' ) {
                  LIST_EMISORES = params.Emisores.split(',')
                  sh "echo $LIST_EMISORES"
                  //sh "ng build --output-path=${ORIGIN}"
              }
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
                sh "echo Deploy"
                sh "ls pexto"
                // sh "aws s3 rm s3://jenkins-test7/${ORIGIN} --recursive"
                // sh "aws s3 cp ${ORIGIN} s3://jenkins-test7/${ORIGIN} --recursive --acl public-read"
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
         slackSend channel: "#jenkins-${PREFIX_BRANCH}",
                   color: 'danger',
                   message: "${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Failed compilation\n❌ Compilation #${BUILD_ID}${env.MESSAGE_ERROR}"
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


