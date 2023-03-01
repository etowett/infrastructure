FROM jenkins/jnlp-slave:4.13.3-1-alpine

USER root

WORKDIR /tmp/workdir

RUN apk --update --no-cache add python3 py3-pip curl

RUN pip install awscli

# Add kubectl client
ENV KUBECTL_VERSION=v1.24.6
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/bin/

# Installing helm
# versions: https://github.com/kubernetes/helm#install
ENV HELM_VERSION=v3.10.0
RUN curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
RUN tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz
RUN cp linux-amd64/helm /usr/bin/

RUN rm -rf /tmp/workdir

ENTRYPOINT ["jenkins-slave"]
