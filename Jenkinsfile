node {
  stage("trigger nais-cd-pipeline") {
    git(url: "https://github.com/nais/naisible.git")
    build(job: "nais_cd_pipeline")
  }
}
