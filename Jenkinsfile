def defineEnvironment() {
    //String ACTUAL_BRANCH_NAME = "${env.BRANCH_NAME}"
    String ACTUAL_BRANCH_NAME = "develop"
    String PREFIX_BRANCH = ""
    String ORIGIN = "pexto"

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
        ORIGIN
    ]
}

pipeline {
    agent any

    environment {
        ACTUAL_BRANCH_NAME = defineEnvironment().get(0)
        PREFIX_BRANCH = defineEnvironment().get(1)
        ORIGIN = defineEnvironment().get(2)
    }

    stages {
        stage('Install') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build') {
            steps {
                sh "npm run build-$ORIGIN-$PREFIX_BRANCH"
            }
        }

        stage('Deploy') {
            steps {
                sh "aws s3 rm s3://jenkins-test7/$ORIGIN --recursive"
                sh "aws s3 cp www s3://jenkins-test7/$ORIGIN --recursive --acl public-read"
            }
        }
    }
}


