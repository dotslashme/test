def dockerRegistry = 'http://localhost:8080'
def nexusRepoCredentials = 'nexus-repo-credentials'
pipeline {
    agent any
    environment {
        scriptSourceDir = "${env.WORKSPACE}/test"
        artemisSourceDir = "${env.WORKSPACE}/activemq_artemis"
    }
    stages {
        stage('cleanUp') {
            steps {
                script {
                    sh "rm -rf ${env.WORKSPACE}/*"
                }
            }
        }
        stage('getScripts') {
            steps {
                script {
                    sh "git clone https://github.com/dotslashme/test.git ${env.scriptSourceDir} && chmod +x ${env.scriptSourceDir}/prepare-sources.bash"
                }
            }
        }
        stage('prepareSources') {
            steps {
                script {
                    activemq_version = sh(returnStdout: true, script: "${env.scriptSourceDir}/prepare-sources.bash ${artemisSourceDir} ${version}").trim()
                }
                script {
                    echo "Switching to: ${env.artemisSourceDir}/artemis-docker"
                    dir("${env.artemisSourceDir}/artemis-docker") {
                        sh "./prepare-docker.sh --from-release --artemis-version ${activemq_version}"
                    }
                }
            }
        }
        stage('buildDockerImage') {
            steps {
                script {
                    dir("${env.artemisSourceDir}/artemis-docker/_TMP_/artemis/${activemq_version}") {
//                        docker.withRegistry(dockerRegistry, nexusRepoCredentials) {
                        artemisImage = docker.build("artemis-centos:${activemq_version}", "-f ./docker/Dockerfile-centos7-11 -t artemis-centos:${activemq_version} .")
//                            artemisImage.push()
//                        }
                    }
                }
            }
        }
    }
}
