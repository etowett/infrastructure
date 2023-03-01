#!groovy

def theServices = [
    [
        'name': 'PG-Restore-from-S3',
        'repo': 'https://gitlab.com/super001/infra.git',
        'filePath': 'jenkins/pipelines/pg-restore-from-s3.groovy',
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
            stringParam('DB_HOST', "10.2.11.10", 'Database Host')
            stringParam('DB_PORT', "5432", 'Database Port')
            stringParam('DB_NAME', "super001", 'Database name')
            stringParam('S3_FILE_NAME', "super001-2022-08-27.sql.gz", 'File name in S3 name')
            stringParam('PG_USER', "super001", 'Postgres User')
            stringParam('PG_PASSWORD', "", 'Postgres Password')
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
