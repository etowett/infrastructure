#!groovy

import groovy.json.JsonOutput

helm_chart_version = "0.1.3"

pipeline {
    agent {
        kubernetes {
            label "build-emailprocessor-${BUILD_NUMBER}"
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-build: emailprocessor-build
    some-label: "build-emailprocessor-${BUILD_NUMBER}"
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              jenkins-build: emailprocessor-build
  imagePullSecrets:
  - name: gitlab-registry-credentials
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: IfNotPresent
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-container-cfg
        mountPath: /kaniko/.docker
  - name: runner
    image: registry.gitlab.com/spin_mobile/infrastructure:runner-v0.1.0
    command:
    - cat
    tty: true
  volumes:
  - name: jenkins-container-cfg
    projected:
      sources:
      - secret:
          name: gitlab-registry-credentials
          items:
            - key: .dockerconfigjson
              path: config.json
"""
        }
    }

    environment {
        githubCredential = 'gitlab-auth-token'
        GITLAB_CREDENTIALS = credentials('gitlab-auth-token')
    }

    stages {
        stage('Cloning the project from git') {
            steps {
            	git branch: "${env.BRANCH_NAME}",
				    credentialsId: githubCredential,
				    url: 'https://gitlab.com/super001/processor.git'
            }
        }

        stage('Build and push the container image to the registry') {
          environment {
            COMMIT_ID = sh(returnStdout: true, script: 'git rev-parse HEAD')
          }
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              withEnv(['PATH+EXTRA=/busybox']) {
                sh """#!/busybox/sh -xe
                  /kaniko/executor \
                    --dockerfile emailprocessor/Dockerfile \
                    --context `pwd`/emailprocessor \
                    --insecure \
                    --skip-tls-verify \
                    --destination registry.gitlab.com/super001/processor:emailprocessor-${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)}
                """
              }
            }
          }
        }

        stage('Helm deploy') {
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
              container('runner') {
                sh """
                  export AWS_ACCESS_KEY_ID=${accessID}
                  export AWS_SECRET_ACCESS_KEY=${accessKey}
                  export AWS_REGION=eu-west-1
                  export AWS_DEFAULT_REGION=eu-west-1

                  cd emailprocessor

                  aws eks --region \${AWS_REGION} update-kubeconfig --name live-main

                  helm repo add --username ${GITLAB_CREDENTIALS_USR} --password ${GITLAB_CREDENTIALS_PSW} spinm \
                      https://gitlab.com/api/v4/projects/34139909/packages/helm/stable

                  helm repo update

                  echo "Doing an upgrade for live-${env.COUNTRY} tag - ${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} branch ${env.BRANCH_NAME}"

                  helm upgrade --install -i --debug emailprocessor spinm/app \
                      --version ${helm_chart_version} \
                      --namespace=live-${env.COUNTRY} \
                      --wait \
                      --timeout 300s \
                      --set image.tag=emailprocessor-${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} \
                      -f helm/live-${env.COUNTRY}.yaml

                  kubectl rollout status -n live-${env.COUNTRY} deployment emailprocessor-app
                """
              }
            }
          }
        }
    }
}
