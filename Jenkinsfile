
node {
    def committer, committerEmail, changelog // metadata

    try {
        stage("checkout") {
                git url: "ssh://git@stash.devillo.no:7999/aura/ansible-nais.git"
        }

        stage("initialize") {

             committer = sh(script: 'git log -1 --pretty=format:"%ae (%an)"', returnStdout: true).trim()
             committerEmail = sh(script: 'git log -1 --pretty=format:"%ae"', returnStdout: true).trim()
        }

    } catch(e) {
        currentBuild.result = "FAILED"
        throw e

        mail body: message, from: "jenkins@aura.adeo.no", subject: "FAILED to complete ${env.JOB_NAME}", to: committerEmail

        def errormessage = "see jenkins for more info ${env.BUILD_URL}\nLast commit ${changelog}"

    }
}

