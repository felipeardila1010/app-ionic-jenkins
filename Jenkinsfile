def defineEnvironment() {
    //String ACTUAL_BRANCH_NAME = "${env.BRANCH_NAME}"
    String ACTUAL_BRANCH_NAME = "develop"
    String PREFIX_BRANCH = ""
    String ORIGIN = "pexto"
    String NAME_COMPONENT_JENKINS = "${env.JOB_NAME.split("/")[0]}"

    switch(ACTUAL_BRANCH_NAME) {
      case "develop":
        PREFIX_BRANCH = "dev"
        break
      case ["master"]:
        PREFIX_BRANCH = "prod"
        break
      default:
        PREFIX_BRANCH = "dev"
        break
    }

    return [
        ACTUAL_BRANCH_NAME,
        PREFIX_BRANCH,
        ORIGIN,
        NAME_COMPONENT_JENKINS
    ]
}

pipeline {
    agent any

    environment {
        ACTUAL_BRANCH_NAME = defineEnvironment().get(0)
        PREFIX_BRANCH = defineEnvironment().get(1)
        ORIGIN = defineEnvironment().get(2)
        NAME_COMPONENT_JENKINS = defineEnvironment().get(3)
    }

    stages {

        stage('Notify start in slack') {
            environment {
                COMMIT_INFO = sh (script: 'git --no-pager show -s --format=\'%aN in commit "%s"\'', returnStdout: true).trim()
            }
            steps {
                script {
                    slackFirstMessage = slackSend(channel: "#jenkins-$ACTUAL_BRANCH_NAME",
                          message: "$NAME_COMPONENT_JENKINS » $ACTUAL_BRANCH_NAME #$BUILD_ID - #$BUILD_ID Started compilation (<$BUILD_URL|Open>)\n📣 Compilation #$BUILD_ID Started by ${COMMIT_INFO}")
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
                sh "aws s3 rm s3://jenkins-test7/$ORIGIN --recursive"
                sh "aws s3 cp www s3://jenkins-test7/$ORIGIN --recursive --acl public-read"
            }
        }
    }
}


