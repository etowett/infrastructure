#!groovy

import groovy.json.JsonOutput

helm_chart_version = "0.1.3"

pipeline {
    agent {
        kubernetes {
            label "build-non-live-app0101-${BUILD_NUMBER}"
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-build: non-live-app0101-build
    some-label: "build-non-live-app0101-${BUILD_NUMBER}"
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              jenkins-build: non-live-app0101-build
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
    image: registry.gitlab.com/super001/infrastructure:runner-v0.1.0
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
				    url: 'https://gitlab.com/super001/app0101.git'
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
                    --dockerfile Dockerfile \
                    --context `pwd`/ \
                    --insecure \
                    --skip-tls-verify \
                    --destination registry.gitlab.com/super001/app0101:${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)}
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

                  aws eks --region \${AWS_REGION} update-kubeconfig --name unstable-main

                  helm repo add --username ${GITLAB_CREDENTIALS_USR} --password ${GITLAB_CREDENTIALS_PSW} spinm \
                      https://gitlab.com/api/v4/projects/34139909/packages/helm/stable

                  helm repo update

                  echo "Doing an upgrade for non-live tag - ${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} branch ${env.BRANCH_NAME}"

                  helm upgrade --install -i --debug app0101 spinm/app \
                      --version ${helm_chart_version} \
                      --namespace=dev \
                      --wait \
                      --timeout 300s \
                      --set image.tag=${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} \
                      --set hook.image.tag=${env.BRANCH_NAME.replaceAll('/', '-')}-${COMMIT_ID.take(10)} \
                      -f helm/dev.yaml

                  kubectl rollout status -n dev deployment app0101-app
                """
              }
            }
          }
        }
    }
}
