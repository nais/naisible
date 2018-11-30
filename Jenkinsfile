node {
  stage("trigger nais-cd-pipeline") {
    git(credentialsId: 'navikt-ci', url: "https://github.com/nais/naisible.git")
    build(job: "nais_cd_pipeline")
  }
}
