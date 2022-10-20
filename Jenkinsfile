pipeline {
    agent any
    environment {
        artemisSourceDir = "${env.WORKSPACE}/activemq_artemis"
    }
    stages {
        stage('prepareSources') {
            steps {
                script {
                    sh "chmod u+x ${env.WORKSPACE}/prepare-sources.bash"
                    activemq_version = sh(returnStdout: true, script: "${env.WORKSPACE}/prepare-sources.bash ${artemisSourceDir} ${version}").trim()
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
                        docker.withRegistry('http://nexus:8081/repository/docker', 'nexus-credentials') {
                            def artemisImage = docker.build("artemis-centos7-11:${activemq_version}", "-f ./docker/Dockerfile-centos7-11 -t artemis-centos7-11:${activemq_version} .")
                            artemisImage.push()
                        }
                    }
                }
            }
        }
    }
}
