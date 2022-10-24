def activemq_version = ""
def docker_version = ""
pipeline {
    agent any
    environment {
        artemis_source_dir = "${env.WORKSPACE}/activemq-artemis"
    }
    stages {
        stage('prepareSources') {
            steps {
                script {
                    (activemq_version,docker_version) = sh(returnStdout: true, script: "${env.WORKSPACE}/prepare-sources.bash ${env.artemis_source_dir} ${activemq_version}").trim().tokenize('|')
                    echo "Artemis version: ${activemq_version}"
                    echo "Docker version: ${docker_version}"
                }
                script {
                    if (activemq_version.trim().equals("latest")) {
                        echo "We are now building everything from scratch"
                        dir("${env.artemis_source_dir}/artemis-distribution") {
                            sh "mvn clean package"
                            activemq_version = sh(returnStdout: true, script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout")
                        }
                        dir("${env.artemis_source_dir}/artemis-docker") {
                            echo "Preparing docker built from latest commit"
                            sh "./prepare-docker.sh --from-local-dist --local-dist-path ${env.artemis_source_dir}/artemis-distribution/target/apache-artemis-${activemq_version}-bin/apache-artemis-${activemq_version}"
                            echo "Docker version: ${docker_version}, Artemis version: ${activemq_version}"
                        }
                    } else {
                        dir("${env.artemis_source_dir}/artemis-docker") {
                            echo "Prepare docker built from release ${activemq_version}"
                            sh "./prepare-docker.sh --from-release --artemis-version ${activemq_version}"
                            echo "Docker version: ${docker_version}, Artemis version: ${activemq_version}"
                        }
                    }
                }
            }
        }
        stage('buildDockerImage') {
            steps {
                script {
                    if (docker_version.trim().equals("latest")) {
                        echo "Building docker latest image"
                        dir("${env.artemis_source_dir}/artemis-distribution/target/apache-artemis-${activemq_version}-bin/apache-artemis-${activemq_version}") {
                            def artemisImage = docker.build("artemis-centos7-11:${docker_version}", "-f ./docker/Dockerfile-centos7-11 -t artemis-centos7-11:${docker_version} .")
                            //artemisImage.push()
                        }
                    } else {
                        echo "Building docker release image"
                        dir("${env.artemis_source_dir}/artemis-docker/_TMP_/artemis/${activemq_version}") {
                            def artemisImage = docker.build("artemis-centos7-11:${docker_version}", "-f ./docker/Dockerfile-centos7-11 -t artemis-centos7-11:${docker_version} .")
//                          artemisImage.push()
                        }
                    }
                }
            }
        }
    }
}
