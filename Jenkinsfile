//println(inventoryList.keySet().getClass())
def envList = []
def releaseList = []
def services = [:]
def execEnvs = []
def execServices = []
def envInput
def release
def releaseJson
def releaseVersion
def ReleaseFile
def deployment_type
import groovy.json.JsonSlurper
def envListJson
import groovy.json.JsonSlurperClassic
def currentCount
def ansibledir='../infrastructure/ansible'
def configdir='../md-aws-config/config'
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
                        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'ybernstein_with_token_full_perm', url: 'https://github.com/intclassproject/Release.git']]])
                    }
                    dir ('infrastructure') {
                        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'ybernstein_with_token_full_perm', url: 'https://github.com/intclassproject/Infrastructure.git']]])
                        }
                    }
                }
            }
        }
        stage ('Choose Environments') {
            steps {
                script {
                    dir('Release') {
                        releaseFile = jsonParse()
                    }

                }
            }
        }
        stage ('Preparations') {
            steps {
                script {
                    dir ('./release') {
                        println(ReleaseFile['release']['name'])
                        for ( service in (ReleaseFile['release']['services']).keySet() ) {
                            execServices.add(service)
                        }
                        println("[INFO] Services affected are : ${execServices}")
                        deployment_type = ReleaseFile['release']['type']
                        println("[INFO] The release is for ${deployment_type}")
                        infrastructureVersion = ReleaseFile['release']['resources']['infrastructure']['version']
                        dir ('./infrastructure') {
                            sh "git checkout ${infrastructureVersion}"
                        }
                    }
                    dir('toDeploy') {
                        for (env in execEnvs) {
                            sh "mkdir -p ${env}"
                            sh "cp -a ${ansibledir}/* ./${env}/"
                            println(envListJson)
                            println(env)
                            awsRegion = envListJson['environments']['aws']["${env}"]['aws_region']
                            sh "sed -i \'s/REGION_NAME/${awsRegion}/g\' ./${env}/inventory.aws_ec2.yml"
                            for ( service in execServices ) {
                                externalConfigVersion = ReleaseFile['release']['services']["${service}"]['external_config']
                                sh "git -C ${configdir} checkout MD.${externalConfigVersion}"
                                sh "cp -a ${configdir}/${service}/* ./${env}/roles/${service}/files/"
                                serviceVersion = ReleaseFile['release']['services']["${service}"]['version']
                                sh "sed -i \'s/SERVICE_VERSION/${serviceVersion}/g\' ./${env}/roles/${service}/vars/main.yml"
                            }
                        }
                    }
                }
            }
        }
        stage ('Align Instances amount') {
            steps {
                script {
                    for ( env in execEnvs ) {
                        dir ("./toDeploy/${env}") {
                            for ( service in execServices ) {
                                def inventoryList = sh script:"ansible-inventory -i inventory.aws_ec2.yml --list", returnStdout: true
                                inventoryList = jsonParse(inventoryList)
                                def serviceFormatted = service.replaceAll('-','_')
                                tempinventoryList = inventoryList.keySet().toArray()
                                println(" tempinventoryList is ${tempinventoryList}")
                                if ( tempinventoryList.contains("service_${env}_${serviceFormatted}") ) {
                                    def currentCountList = (inventoryList["service_${env}_${serviceFormatted}"]['hosts'])
                                    currentCount = currentCountList.size
                                    println("[INFO] Found ${currentCount} of instances of ${env}_${service}")
                                    println("[INFO] Instances found are: ${currentCountList}")
                                }
                                else {
                                    println("[INFO ] Found no hosts at all - worry you shall not")
                                    currentCount = 0
                                }
                                def desiredCount = ReleaseFile['release']['services']["${service}"]['instances_count']
                                int intdesiredCount = desiredCount.toInteger()
                                int intcurrentCount = currentCount.toInteger()
                                    if ( intdesiredCount > intcurrentCount ) {
                                        int countAdd = intdesiredCount - intcurrentCount;
                                        println("[INFO] Release asks for ${desiredCount} of ${service} in ${env} but only ${currentCount} found")
                                        println("[INFO] Will add ${countAdd} instances of ${service}")
                                        println(envListJson)
                                        awsRegion = envListJson['environments']['aws']["${env}"]['aws_region']
                                        //awsRegion = awsRegion.trim()
                                        def instanceType = ReleaseFile['release']['services']["${service}"]['instance_type']
                                        def subnetScope = ReleaseFile['release']['services']["${service}"]['scope']
                                        vpc = envListJson['environments']['aws']["${env}"]['aws_region']["${deployment_type}-vpc"]['name']
                                        subnetPrefix = envListJson['environments']['aws']["${env}"]['aws_region']["${deployment_type}-vpc"]['subnet_prefix']

                                        if ( subnetScope == "public" ) {
                                            def publicip = "true"
                                            println("publicip is ${publicip}")
                                        } else {
                                            def publicip = "false"
                                            println("publicip is ${publicip}")
                                        }
                                        dir("./terraform") {
                                            try {
                                                sh "rm -f terraform/terraform.tfstate*"
                                                sh "ansible-playbook infra.yaml --extra-vars 'state=present aws_region=${awsRegion} instanceType=${instanceType} count=${countAdd} instanceName=${env}_${service} vpc=${vpc} deployment_type=${deployment_type} serviceName=${env}_${service} env=${env} serviceVersion=${serviceVersion} releaseVersion=${releaseVersion} subnetPrefix=${subnetPrefix} subnetScope=${subnetScope} publicip=${publicip}'"
                                            } catch (err) {
                                                println("[ERROR] Running Ansible to create an instance for ${service}")
                                            }
                                            sh "rm -f terraform/terraform.tfstate*"
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        stage ('Sign The Contract') {
            steps {
                script {
                    sleep(time:60,unit:"SECONDS")
                    def signContract
                    signContract.toString()
                    signContract = input message: "Do you confess?",
                    ok: 'In God I trust',
                    parameters: [choice(name: '', choices: ['GO', 'STOP'], description: " -----\n Environments: ${execEnvs}\n Services: ${execServices}\n ")]
                        if (signContract == 'STOP') {
                            autoCancelled = true
                            error('Aborted')
                            currentBuild.result = 'FAILURE'
                            return
                        }
                }
            }
        }
        stage ('Deploy Services') {
            steps {
                script {
                    for (env in execEnvs) {
                        dir("toDeploy/${env}") {
                            zookeeperCluster =
                            zookeeperCluster = zookeeperCluster.toString()
                            for ( service in execServices ) {
                                try {
                                    sh "ansible-playbook -i inventory.aws_ec2.yml env_deployment.yml --tags=${service} --extra-vars 'aws_environment=${env} zookeeper=${zookeeperCluster} service=${service} ansible_python_interpreter=/usr/bin/python3 apm_server_url=http://monitor.kampyle.com:4401 deployment_type=${deployment_type} aws_vpc=digital-${deployment_type} aws_region=${awsRegion}'"
                                } catch (err) {
                                    println("[ERROR] Running Ansible for ${service} deploy")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}




if (req.http.url !~ "^/kma/api") {
  set req.url = "/index.html"
}