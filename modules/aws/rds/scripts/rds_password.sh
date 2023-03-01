#!/bin/bash
set -e
eval "$(jq -r '@sh "export DEVOPS_SECRET_ARN=\(.devops_secret_arn) AWS_REGION=\(.aws_region)"')"
if [[ -z "${DEVOPS_SECRET_ARN}" ]]; then export DEVOPS_SECRET_ARN=none; fi
if [[ -z "${AWS_REGION}" ]]; then export AWS_REGION=none; fi
PASSWORD=$(aws secretsmanager get-secret-value --secret-id "${DEVOPS_SECRET_ARN}" --region "${AWS_REGION}" | jq --raw-output '.SecretString' |jq --raw-output ".password")
echo -n "{\"password\":\"${PASSWORD}\"}"
