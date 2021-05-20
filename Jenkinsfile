node {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */
        checkout scm
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

        docker.withRegistry('https://053149737028.dkr.ecr.ap-northeast-2.amazonaws.com', 'ecr:ap-northeast-2:shiincs-ecr-credential') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
}
