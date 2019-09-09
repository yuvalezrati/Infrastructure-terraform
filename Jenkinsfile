def BuildVersion
pipeline {
    options {
        timeout(time: 30, unit: 'MINUTES')

    }
    environment {
        registry = "dockerhubuser/repo"
        registryCredential = 'dockerhub'
        dockerImage = ''
    }
    agent {
        label 'master'
    }
    stages {
        stage ('Checkout') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: git_cred_id, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        dir(release_dir) {
                            deleteDir()
                            checkout([$class: 'GitSCM', branches: [[name: dev_branch]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: git_cred_id, url: "$scm_url/$GIT_USERNAME/$release_repo"]]])

                        }
                        dir(expiremnt_dir) {
                            deleteDir()
                            checkout([$class: 'GitSCM', branches: [[name: dev_branch]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: git_cred_id, url: "$scm_url/$GIT_USERNAME/$experiment_repo"]]])
                            result = sh(script: 'git branch -r | grep -q 1.*', returnStatus: true)
                            if (!result)
                                Current_version = sh(script: "git branch -r | sed 's/[^0-9\\.]*//g' | sort -r | head -n 1", returnStdout: true).trim()
                            else
                                Current_version = initial_version
                            Commit_Id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                            Build_version = Current_version + underscore + Commit_Id
                            println("Checking the build version: $Build_version")
                            last_digit_current_version = sh(script: "echo $Current_version | cut -d$dot -f3", returnStdout: true).trim()
                            NextVersion = sh(script: "echo $Current_version | cut -d$dot -f1", returnStdout: true).trim() + dot + sh(script: "echo $Current_version |cut -d$dot -f2", returnStdout: true).trim() + dot + (Integer.parseInt(last_digit_current_version) + 1)


                        }
                    }
                }
            }
        }
        stage('Syntex checking'){

        }
    }
}

