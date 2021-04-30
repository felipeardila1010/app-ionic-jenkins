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

        stage("SonarQube Analysis") {
            steps {
                sh "docker run --rm -v /root/.m2:/root/.m2 -v $WORKSPACE:/app -w /app \
                                      maven:3-alpine mvn sonar:sonar \
                                          -Dsonar.projectKey=$NAME_COMPONENT_JENKINS \
                                          -Dsonar.host.url=http://sonarqube.qa.cobre.co \
                                          -Dsonar.login=d3f4b3583131da7da2430ea151ba73ae9b109821 \
                                          -Dsonar.java.binaries=./src"
            }
        }

        stage("Deploy") {
            steps {
                sh "aws s3 rm s3://jenkins-test7/$ORIGIN --recursive"
                sh "aws s3 cp www s3://jenkins-test7/$ORIGIN --recursive --acl public-read"
            }
        }
    }
}


