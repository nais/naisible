
node {
    def committer, committerEmail, changelog // metadata

    try {
        stage("init") {
                git url: "https://github.com/nais/naisible.git"
			dir("nais-inventory"){
                git url: "ssh://git@stash.devillo.no:7999/aura/nais-inventory.git"
			}

            committer = sh(script: 'git log -1 --pretty=format:"%ae (%an)"', returnStdout: true).trim()
            committerEmail = sh(script: 'git log -1 --pretty=format:"%ae"', returnStdout: true).trim()
        }

        stage("teardown") {
			sh('ansible-playbook -i ./nais-inventory/ci teardown-playbook.yaml')
        }

        stage("setup") {
			sh('ansible-playbook -i ./nais-inventory/ci setup-playbook.yaml')
        }

        stage("test") {
			sleep 15 // allow addons to start
			sh('ansible-playbook -i ./nais-inventory/ci test-playbook.yaml')
        }

    } catch(e) {
        currentBuild.result = "FAILED"
        throw e

        mail body: message, from: "jenkins@aura.adeo.no", subject: "FAILED to complete ${env.JOB_NAME}", to: committerEmail

        def errormessage = "see jenkins for more info ${env.BUILD_URL}"
    }
}

