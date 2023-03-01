#!groovy

helm_chart_version = "0.1.2"

pipeline {
    agent any

    environment {
        dockerRegistry = 'registry.gitlab.com/super001/app0102'
        githubCredential = 'gitlab-auth-token'
        gitlabUser = 'api-token'
        gitlabToken = 'glpat-s3bEXJ2aVzxHPnftNuyy'
        registryCredential = "gitlab-container-registry-token"
        dockerImage = ""
    }

    stages {

        stage('Cloning the project from git') {
            steps {
            	git branch: "${env.BRANCH_NAME}",
				    credentialsId: githubCredential,
				    url: 'https://gitlab.com/super001/app0102.git'
            }
        }

        stage('Build the deploy image') {
            environment {
                COMMIT_ID = sh(returnStdout: true, script: 'git rev-parse HEAD')
            }
            steps {
                script {
                    echo "Bulding docker images"
                    dockerImage = docker.build("${dockerRegistry}:${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)}")
                }
            }
        }

        stage('Publish container image to gitlab docker registry') {
            steps {
                script {
                    echo "Pushing docker image"
                    docker.withRegistry('https://registry.gitlab.com', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy app to eks') {
            environment {
                COMMIT_ID = sh(returnStdout: true, script: 'git rev-parse HEAD')
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-terraform-user',
                        usernameVariable: 'accessID',
                        passwordVariable: 'accessKey'
                    )
                ]) {
                    script {
                        sh"""#!/bin/bash -e
                            export AWS_ACCESS_KEY_ID=${accessID}
                            export AWS_SECRET_ACCESS_KEY=${accessKey}
                            export AWS_REGION=eu-west-1
                            export AWS_DEFAULT_REGION=eu-west-1

                            aws eks --region \${AWS_REGION} update-kubeconfig --name live-main

                            helm repo add --username ${gitlabUser} --password ${gitlabToken} spinm \
                                https://gitlab.com/api/v4/projects/34139909/packages/helm/stable

                            helm repo update

                            echo "Doing an upgrade for live-${env.COUNTRY} tag - ${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} branch ${env.BRANCH_NAME}"

                            helm upgrade --install -i --debug app0102-app spinm/app \
                                --version ${helm_chart_version} \
                                --namespace=live-${env.COUNTRY} \
                                --wait \
                                --timeout 300s \
                                --set image.tag=${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} \
                                --set hook.image.tag=${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} \
                                -f helm/live-${env.COUNTRY}.yaml

                            kubectl rollout status -n live-${env.COUNTRY} deployment app0102-app
                        """
                    }
                }
            }
        }
    }
}
