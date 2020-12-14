node {
  stage("trigger nais-cd-pipeline") {
    git(url: "https://github.com/nais/naisible.git")

    skipCi = sh(script: "git log --pretty=format:'%s' -1 | grep -P '\\[skip[- ]ci\\]'", returnStatus: true)
    if ( skipCi == 0 ) {
      echo "Skipping"
    } else {
      build(job: "nais_cd_pipeline")
    }
  }
}
