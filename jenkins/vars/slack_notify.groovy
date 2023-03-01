#!/usr/bin/env groovy
import groovy.json.JsonOutput

def call() {
	def job_name = "${env.JOB_NAME}".split('/')[0]
    def job_link_name = job_name.replace(" ", "%20")
    def repo_name = "${env.GIT_URL}".replace(".git", "")
	def commitHashShort = "${GIT_COMMIT}".take(10)

	switch ( "${currentBuild.currentResult}" ) {
	    case "SUCCESS":
	        color = '#36a64f'
	    default:
	        color = '#ff0000'
	}

    def payload = JsonOutput.toJson([
        text: "*${job_name} build information*",
        username: "super001 Jenkins",
        icon_emoji: ":jenkins:",
        channel: "${NOTIFICATION_CHANNEL}",
        attachments: [[
            	color: "${color}",
                title: "Jenkins build #${env.BUILD_NUMBER} for ${job_name}",
                text: "*Build Status:* ${currentBuild.currentResult}\
                \n*Branch Name:* ${env.BRANCH_NAME}\
                \n*Commit Hash:* ${GIT_COMMIT}\
                \n*Version:* ${env.BRANCH_NAME}-${commitHashShort}",
                actions: [[
		          type: "button",
		          text: "View Job in Jenkins",
		          url: "http://spinm-jenkins.in.super001.com:8080/blue/organizations/jenkins/${job_link_name}/detail/${env.BRANCH_NAME}/${env.BUILD_NUMBER}/pipeline",
		          style: "secondary"

                ],[
		          type: "button",
		          text: "View Commit in GitHub",
		          url: "${repo_name}/commit/${GIT_COMMIT}",
		          style: "secondary"

                ]]
        ]]
    ])

  sh "curl -s -X POST -H 'Content-Type: application/json' -d '${payload}' ${SLACK_WEBHOOK} "
}
