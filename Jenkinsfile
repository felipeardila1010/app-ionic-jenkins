def getValueEmisor(originToSearch) {
  def origins = [
    "pxt": "pxt01,pexto",
    "fjy": "fjy03,fujiyama",
    "smx": "smx04,solmex",
    "bmt": "bmt02,barumotors",
    "gmt": "gmt06,gematours"
  ]

  return origins[originToSearch.toLowerCase()]
}

def defineEnvironment() {
    // Static variables
    String ORIGINS_AVAILABLE_DEV = "pxt"
    String ORIGINS_AVAILABLE_PROD = "pxt,fjy,bmt,smx,gmt"

    // Custom variables
    String ACTUAL_BRANCH_NAME = "${env.BRANCH_NAME}"
    String PREFIX_BRANCH = ""
    String PREFIX_BRANCH_S3 = ""
    String ENVIRONMENT = ""
    String NAME_COMPONENT_JENKINS = "${env.JOB_NAME.split("/")[0]}"
    String[] ORIGINS_AVAILABLE

    switch(ACTUAL_BRANCH_NAME) {
      case "develop":
        PREFIX_BRANCH = "dev"
        PREFIX_BRANCH_S3 = "dev"
        ENVIRONMENT = "develop"
        ORIGINS_AVAILABLE = ORIGINS_AVAILABLE_DEV.split(',')
        break
      case "master":
        PREFIX_BRANCH = "prod"
        PREFIX_BRANCH_S3 = ""
        ENVIRONMENT = "production"
        ORIGINS_AVAILABLE = ORIGINS_AVAILABLE_PROD.split(',')
        break
      default:
        PREFIX_BRANCH = "dev"
        PREFIX_BRANCH_S3 = "dev"
        ENVIRONMENT = "develop"
        ORIGINS_AVAILABLE = ORIGINS_AVAILABLE_DEV.split(',')
        break
    }

    return [
        ACTUAL_BRANCH_NAME,
        PREFIX_BRANCH,
        PREFIX_BRANCH_S3,
        NAME_COMPONENT_JENKINS,
        ENVIRONMENT,
        ORIGINS_AVAILABLE
    ]
}

def addEmoji(emoji) {
    if (slackFirstMessage != null) {
        slackFirstMessage.addReaction(emoji)
    }
}

def responseFirstMessageAbort() {
    if (slackFirstMessage != null) {
//         slackSend(channel: slackFirstMessage.threadId,
//                         color: 'warning',
//                         message: "Compilation #${BUILD_ID} Aborted \n${sh(script:'wget --auth-no-challenge --user=smolina --password=1195c3d78f17d23dce759ac1fbe37497cb -O - $BUILD_URL/consoleText | grep \'Aborted by\'', returnStdout: true).substring(27)}")
    }
}
def responseSlackError() {
    if (slackFirstMessage != null) {
        //slackSend(channel: slackFirstMessage.threadId, message: "*LOGS*\nErrors found in log:\n```${sh(script:'wget --auth-no-challenge --user=smolina --password=1195c3d78f17d23dce759ac1fbe37497cb -O - $BUILD_URL/consoleText | grep \'ERROR:\\|error\\|Error\\|\\[ERROR\\]\'', returnStdout: true)}```")
    }
}

def defineEmisores(){
  def LIST_EMISORES = []
  def FINAL_LIST_EMISORES = []
  def STRING_FINAL_LIST_EMISORES = []
  if ((params.Emisores != '' && ENVIRONMENT == 'production') || (ENVIRONMENT == 'develop')) {
      LIST_EMISORES = params.Emisores.split(',')
      for (emisor in LIST_EMISORES) {
        if(env.ORIGINS_AVAILABLE.contains((emisor.toLowerCase()))) {
          FINAL_LIST_EMISORES.add(emisor)
        }
      }

      if(FINAL_LIST_EMISORES.size() > 0) {
        env.STRING_FINAL_LIST_EMISORES = FINAL_LIST_EMISORES.join(",")
        sh "echo Emisores a desplegar= $FINAL_LIST_EMISORES"
      } else {
        env.MESSAGE_ERROR = '\nNo se ha encontrado ningun emisor disponible para el deploy del pipeline'
        error(env.MESSAGE_ERROR)
      }
  } else {
    env.MESSAGE_ERROR = '\nNo se ha seleccionado ningun Emisor para el deploy del pipeline'
    error(env.MESSAGE_ERROR)
  }
}

// Run Steps of the Pipeline
pipeline {
    agent any

    environment {
        defineEnvironment = defineEnvironment()
        ACTUAL_BRANCH_NAME = defineEnvironment.get(0)
        PREFIX_BRANCH = defineEnvironment.get(1)
        PREFIX_BRANCH_S3 = defineEnvironment.get(2)
        NAME_COMPONENT_JENKINS = defineEnvironment.get(3)
        ENVIRONMENT = defineEnvironment.get(4)
        ORIGINS_AVAILABLE = defineEnvironment.get(5)
    }

    parameters {
        checkboxParameter(name:'Emisores', valueNodePath: '//CheckboxParameter/value', displayNodePath: '//CheckboxParameter/text', description: 'Emisores para desplegar', format:'JSON', uri:'https://cobre-utils.s3.us-east-2.amazonaws.com/pipeline/emisores.json')
        string(name: 'CustomBranchForDeploy', defaultValue: '', description: 'Branch custom para despliegue *Aplica solo Dev(Rama Develop) **Dejar vacio para desplegar rama por defecto del pipeline')
    }

    stages {
        stage('Preparation') {
            steps {
                script {
                    sh "echo Definiendo emisores a desplegar..."
                    defineEmisores() // Call for define emisores
                    env.PACKAGE_VERSION = sh(script: "grep \"version\" package.json | cut -d '\"' -f4 | tr -d '[[:space:]]'", returnStdout: true)
                    env.messageDeploy = ''

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
                        defineEnvironment()
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
                          message: "FE :iphone: - ${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Started compilation (<${BUILD_URL}|Open>)\n📣 Compilation #$BUILD_ID Started by ${COMMIT_INFO}")
                }
            }
        }

        stage("Install") {
            steps {
                sh "docker run --platform linux/amd64 --rm -v $WORKSPACE:/app -w /app pipekung/angular:node14.2 yarn"
            }
        }

        stage("Build") {
          steps {
            script {
              def listEmisores = env.STRING_FINAL_LIST_EMISORES.split(",")
              for (codeInfraEmisor in listEmisores) {
                valuesOrigin = getValueEmisor(codeInfraEmisor)
                nameOrigin = valuesOrigin.split(",")[1]

                // sh "docker run --rm -v $WORKSPACE:/app -w /app node:14-alpine npm install"
                sh "docker run --platform linux/amd64 --rm -v $WORKSPACE:/app -w /app pipekung/angular:node14.2 ng build --output-path=${nameOrigin} --base-href=/${nameOrigin}/ --deploy-url /${nameOrigin}/"
              }
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
              script {
                def listEmisores = env.STRING_FINAL_LIST_EMISORES.split(",")
                for (codeInfraEmisor in listEmisores) {
                  valuesOrigin = getValueEmisor(codeInfraEmisor)
                  codeOrigin = valuesOrigin.split(",")[0]
                  nameOrigin = valuesOrigin.split(",")[1]

                  nameBucket = "jenkins-test-${codeOrigin}"
                  if(env.PREFIX_BRANCH_S3 != null) {
                    nameBucket = nameBucket + "-${env.PREFIX_BRANCH_S3}"
                  }

                  sh "aws s3 rm s3://${nameBucket}/${nameOrigin} --recursive --quiet"
                  sh "aws s3 cp ${nameOrigin} s3://${nameBucket}/${nameOrigin} --recursive --quiet --acl public-read"
                  env.messageDeploy = env.messageDeploy.concat(":this-is-fine-fire: Deploy complete for emisor `$nameOrigin` in environment `$ENVIRONMENT` \n")
                }
              }
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
                   message: "FE :iphone: - ${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Failed compilation\n❌ Compilation #${BUILD_ID}${env.MESSAGE_ERROR}"
         responseSlackError()
       }
       success
       {
         slackSend channel: "#jenkins-${PREFIX_BRANCH}",
                   color: 'good',
                   message: "FE :iphone: - ${NAME_COMPONENT_JENKINS} » ${ACTUAL_BRANCH_NAME} #${BUILD_ID} - #${BUILD_ID} Finish compilation\n✔ Compilation #${BUILD_ID} with image tag `${env.PACKAGE_VERSION}`\n${env.messageDeploy}"
       }
       aborted {
          addEmoji('black_square_for_stop')
          responseFirstMessageAbort()
       }
   }
}


