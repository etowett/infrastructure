#!groovy

def theServices = [
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
            choiceParam('ENV', ['dev'], 'Env to deploy')
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
