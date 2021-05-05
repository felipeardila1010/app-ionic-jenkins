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
  if ( params.Emisores != '' ) {
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
    agent none

    stages {
        stage('Front-end') {
            agent { dockerfile true }
            stages {
              stage('Front-end') {
               sh 'npm install'
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


