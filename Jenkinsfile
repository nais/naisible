pipeline {
  agent any
  environment {
    clusterName = 'knada'
  }

  stages {
    stage('Clone') {
      steps {
	dir("naisible") {
	  git(url: 'https://github.com/navikt/knada-naisible.git')
	}

	dir("nais-inventory") {
	  git(credentialsId: 'nais-inventory',
	      url: "git@github.com:navikt/nais-inventory.git",
	      changelog: false)
	}
      }
    }

    stage('Ansible run') {
      steps {
          sh("./ansible-playbook -f 20 --key-file=/home/jenkins/.ssh/id_rsa -i inventory/${clusterName} -e @inventory/${clusterName}-vars.yaml playbooks/setup-playbook.yaml")
	  sh("./ansible-playbook -f 20 --key-file=/home/jenkins/.ssh/id_rsa -i inventory/${clusterName} -e @inventory/${clusterName}-vars.yaml playbooks/naisflow-playbook.yaml")
      }

      post {
        success {
          sleep 15
          sh("./ansible-playbook -f 20 --key-file=/home/jenkins/.ssh/id_rsa -i inventory/${clusterName} -e @inventory/${clusterName}-vars.yaml playbooks/test-playbook.yaml")
        }
      }
    }
  }

  post {
    always {
      deleteDir()
    }
  }
}
