import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
@NonCPS
def createBooleanParameter(String value, String desc) {
   return [$class: 'BooleanParameterDefinition', defaultValue: false, name: value, description: desc]
}
@NonCPS
def jsonParse(def json) {
    new groovy.json.JsonSlurperClassic().parseText(json)
}
pipeline {
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    agent {
        label 'master'
    }
    stages {
        stage ('Checkout') {
            steps {
                script {
                    deleteDir()
                    dir ('release') {
                        checkout([$class: 'GitSCM', branches: [[name: '*/yuri']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/intclassproject/Release.git']]])
                    }
                    dir ('infrastructure') {
                        checkout([$class: 'GitSCM', branches: [[name: '*/yuri']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/intclassproject/Infrastructure.git']]])
                    }
                    dir ('automation') {
                        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/intclassproject/Automation.git']]])
                    }
                }
            }
        }
        stage ('Load release json') {
            steps {
                script {
                    dir('release') {
                        releaseFile = jsonParse(readFile("dev.json"))
                        releaseName = releaseFile["release"]["name"]
                        releaseVersion = releaseFile["release"]["version"]
                        infrastructureVersion = releaseFile["release"]["infrastructure"]
                        automationVersion = releaseFile["release"]["automation"]
                        servicesList = releaseFile["release"]["services"].keySet()
                        println(servicesList)
                        println("Release Name is ${releaseName}")
                        println("Release Version is ${releaseVersion}")
                        println("Infrastructure Version is ${infrastructureVersion}")
                        println("Automation Version is ${automationVersion}")
                        println("service are: ${servicesList}")
                    }
                    dir('automation') {
                        sh "git checkout ${automationVersion}"
                    }
                    dir('infrastructure') {
                        sh "git checkout ${infrastructureVersion}"
                    }
                }
            }
        }
        stage ('Verify artifacts exist') {
            steps {
                script {
                    for ( service in servicesList ) {
                        serviceVersion = releaseFile["release"]["services"]["${service}"]["version"]
                        try {
                            sh "ls /mnt/artifacts/dev/${service}_${serviceVersion}.tar"
                        } catch('err') {
                            println("Artifact not exists ${service}_${serviceVersion}.tar")
                            currentBuild.result = 'FAILURE'
                        }
                    }
                }
            }
        }
        stage ('Deploy Services') {
            steps {
                script {
                    dir('infrastructure/ansible') {
                        for ( service in servicesList ) {
                            sh "cat hosts.template > hosts"
                            sh "sed -i '/s/all/${service}/g' hosts"
                            ipList = releaseFile["release"]["services"]["${service}"]["servers"]
                                if ( ipList.isEmpty() ) {
                                    println("This ip list is empty for ${service}")
                                    currentBuild.result = 'FAILURE'
                                } else {
                                    for ( ip in ipList ) {
                                        sh "echo ${ip} >> hosts"
                                    }
                                sh "ansible-playbook -i hosts main.yml --extra-vars 'service=${service}'"
                                }
                        }
                    }
                }
            }
        }
    }
  }
