pipeline {
  agent { label 'linux'}

  stages {
    stage ('build') {
      steps {
        git url: "https://github.com/Supriya-Battula/playbook.git",
         branch: 'main'
      }
    }
    stage ('steps') {
      steps {
        sh 'terraform init'
        sh 'terraform apply -auto-approve'
      }
    }
    }
  }
