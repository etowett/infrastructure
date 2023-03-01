#!groovy

def theServices = [
    [
        'name': 'PG-Backup-to-S3',
        'repo': 'https://gitlab.com/super001/infra.git',
        'filePath': 'jenkins/pipelines/pg-backup-to-s3.groovy',
        'branchName': 'main',
    ],
]

theServices.each {
    def jobName = "${it.name}"
    def gitRepo = "${it.repo}"
    def filePath = "${it.filePath}"
    def branchName = "${it.branchName}"

    pipelineJob(jobName) {
        description(jobName)
        displayName(jobName)

        parameters {
            stringParam ('DB_HOST', "10.2.11.10", 'Database Host')
            stringParam ('DB_PORT', "25060", 'Database Port')
            stringParam ('DB_NAME', "radicrunch", 'Database name')
            stringParam ('PG_USER', "radicrunch", 'Postgres User')
            stringParam ('PG_PASSWORD', "", 'Postgres Password')
        }

        properties {
            githubProjectUrl(gitRepo)
        }

        definition {
            cpsScm {
                scm {
                    git {
                        branch(branchName)
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
