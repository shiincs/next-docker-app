node {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */
        checkout scm
    }

    stage('AWS Check') {
        sh '''
            apt-get update
            apt install python3-pip -y
            pip3 install awscli --upgrade
        '''

        sh 'aws --version'
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
        * docker build on the command line */
        app = docker.build("053149737028.dkr.ecr.ap-northeast-2.amazonaws.com/next-docker-app")
    }

    stage('Test image') {
        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
        * First, the incremental build number from Jenkins
        * Second, the 'latest' tag.
        * Pushing multiple tags is cheap, as all the layers are reused. */

        sh 'rm  ~/.dockercfg || true'
        sh 'rm ~/.docker/config.json || true'

        docker.withRegistry(
            'https://053149737028.dkr.ecr.ap-northeast-2.amazonaws.com',
            'ecr:ap-northeast-2:shiincs-user'
        ) {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

//     stage('Deploy AWS') {
//         env.BUILD_ENVIRONMENT = "PROD"
//         env.EB_APPLICATION_NAME = "next-docker-app"
//         env.EB_ENV_NAME = "Nextdockerapp-env"
//
//         withAWS(region: 'ap-northeast-2', credentials: 'shiincs-user') {
//             sh '''
//                 # create Dockerrun.aws.json files
//                 # sed -i "s|GIT_COMMIT_SHA|${GIT_COMMIT}|g" "${WORKSPACE}/Dockerrun.aws.json"
//
//                 # Upload S3
//                 aws s3 cp "${WORKSPACE}/Dockerrun.aws.json" s3://elasticbeanstalk-ap-northeast-2-053149737028/${BUILD_ENVIRONMENT}-${EB_APPLICATION_NAME}-${GIT_COMMIT}.aws.json \
//                     --region ap-northeast-2
//
//                 # Execute Beanstalk
//                 aws elasticbeanstalk create-application-version \
//                     --region ap-northeast-2 \
//                     --application-name ${EB_APPLICATION_NAME} \
//                     --version-label ${GIT_COMMIT}-${BUILD_NUMBER} \
//                     --description ${GIT_COMMIT}-${BUILD_NUMBER} \
//                     --source-bundle S3Bucket="elasticbeanstalk-ap-northeast-2-053149737028",S3Key="${BUILD_ENVIRONMENT}-${EB_APPLICATION_NAME}-${GIT_COMMIT}.aws.json"
//
//                 aws elasticbeanstalk update-environment \
//                     --region ap-northeast-2 \
//                     --environment-name ${EB_ENV_NAME} \
//                     --version-label ${GIT_COMMIT}-${BUILD_NUMBER}
//                 '''
//         }
//     }
}
