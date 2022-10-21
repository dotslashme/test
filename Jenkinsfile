pipeline {
    agent any
    parameters {
        // artemis_version is set when you trigger a build
        artemisSourceDir = "${env.WORKSPACE}/activemq-artemis"
        docker_version = ""
    }
    stages {
        stage('prepareSources') {
            steps {
                script {
                    sh "chmod u+x ${env.WORKSPACE}/prepare-sources.bash"
                    artemis_version = sh(returnStdout: true, script: "${env.WORKSPACE}/prepare-sources.bash ${artemisSourceDir} ${artemis_version}").trim()
                }
                script {
                    if (${artemis_version}.trim().equals("latest")) {
                        dir("${artemisSourceDir/artemis-distribution}") {
                            sh "mvn clean package"
                            docker_version = "latest"
                            artemis_version = sh(returnStdout: true, script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout")
                        }
                        dir("${artemisSourceDir/artemis-docker}") {
                            sh "./prepare-docker.sh --from-local-dist --local-dist-path ${artemisSourceDir}/artemis-distribution/target/apache-artemis-${artemis_version}-bin/apache-artemis-${artemis_version}"
                        }
                    } else {
                        dir("${artemisSourceDir}/artemis-docker") {
                            sh "./prepare-docker.sh --from-release --artemis-version ${activemq_version}"
                            docker_version = "release"
                        }
                    }
                }
            }
        }
        stage('buildDockerImage') {
            steps {
                script {
                    dir("${artemisSourceDir}/artemis-docker/_TMP_/artemis/${activemq_version}") {
                        def artemisImage = docker.build("artemis-centos7-11:${docker_version}", "-f ./docker/Dockerfile-centos7-11 -t artemis-centos7-11:${docker_version} .")
//                         artemisImage.push()
                    }
                }
            }
        }
    }
}
