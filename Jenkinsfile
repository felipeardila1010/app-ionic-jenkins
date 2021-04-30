def defineEnvironment() {
    String actualBranchName = "${env.GIT_BRANCH}"
    String origin = "pexto"

    return [
        "${actualBranchName}",
        "${origin}"
    ]
}

pipeline {
    agent any

    environment {
        ACTUAL_BRANCH_NAME = defineEnvironment().get(0)
        ORIGIN = defineEnvironment().get(1)
    }

    stages {
        stage('Install') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build') {
            steps {
                sh "npm run build-$ORIGIN-$ACTUAL_BRANCH_NAME"
            }
        }
    }
}


