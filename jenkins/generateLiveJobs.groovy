#!groovy

def theServices = [
    [
        'name': 'Live-StatementWorkflowProcessor',
        'repo': ' https://gitlab.com/super001/infra.git',
        'filePath': 'jenkins/k8s-pipelines/deploy-statementworkflowprocessor.groovy',
        'branchName': 'release-v1.0.0',
    ],
]

theServices.each {
    def jobName = "${it.name}"
    def gitRepo = "${it.repo}"
    def filePath = "${it.filePath}"
    def branchName = "${it.branchName}"
    def envApp = "${it.envApp}"
    def envsEnabled = "${it.devEnvsEnabled}"

    pipelineJob(jobName) {
        description(jobName)
        displayName(jobName)

        parameters {
            stringParam('BRANCH_NAME', branchName, 'Branch to build')
            choiceParam('COUNTRY', ['ug', 'rw'], 'Country to target')
        }

        properties {
            githubProjectUrl(gitRepo)
        }

        definition {
            cpsScm {
                scm {
                    git {
                        branch("refs/heads/main")
                        remote {
                            url(gitRepo)
                            name('origin')
                            credentials('gitlab-auth-token')
                        }
                        extensions {
                            cleanBeforeCheckout()
                        }
                    }
                    scriptPath(filePath)
                }
            }
        }
    }
}
