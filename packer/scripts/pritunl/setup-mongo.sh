#!/bin/bash -xe

sudo tee /etc/yum.repos.d/mongodb-org-5.0.repo << EOF
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc
EOF

sudo dnf -y install mongodb-org

sudo systemctl enable --now mongod
