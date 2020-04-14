FROM hashicorp/terraform:0.12.24

RUN apk -Uuv add ca-certificates openssl groff less git bash wget make jq curl unzip sed

WORKDIR /app

ENTRYPOINT ["/bin/terraform"]

CMD ["--help"]

ENV USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"

ENV TERRAFORM_RKE_VERSION=1.0.0-rc5
ENV RKE_FILENAME=terraform-provider-rke_linux-amd64
ENV RKE_TERRAFORM_URL=https://github.com/yamamoto-febc/terraform-provider-rke/releases/download/${TERRAFORM_RKE_VERSION}/${RKE_FILENAME}

ENV RKE_TERRAFORM_SHA256SUM=

RUN echo "Install Terraform plugin from:" \
  && echo "${RKE_TERRAFORM_URL}"
RUN mkdir -p ~/.terraform.d/plugins/
RUN wget -q --user-agent="${USER_AGENT}" ${RKE_TERRAFORM_URL}
RUN chmod +x ${RKE_FILENAME}
RUN mv ${RKE_FILENAME} ~/.terraform.d/plugins/

ENV RKE_VERSION=v1.0.6
RUN wget -q --user-agent="${USER_AGENT}" https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_linux-amd64
RUN chmod +x rke_linux-amd64
RUN mv rke_linux-amd64 /usr/bin/rke

# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.16.5"

RUN wget -q --user-agent="${USER_AGENT}" https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/bin/helm \
    && chmod +x /usr/bin/helm

ENV HELM_VERSION3="v3.1.2"

RUN wget -q --user-agent="${USER_AGENT}" https://get.helm.sh/helm-${HELM_VERSION3}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/bin/helm3 \
    && chmod +x /usr/bin/helm3
RUN helm3 plugin install https://github.com/helm/helm-2to3

RUN apk add --no-cache musl-dev go && \
    export PATH=$PATH:$(go env GOPATH)/bin && export GOPATH=$(go env GOPATH) && \
    go get -u github.com/ericchiang/terraform-provider-k8s && \
    mv /$GOPATH/bin/terraform-provider-k8s ~/.terraform.d/plugins/ && \
    apk del musl-dev go

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl

RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

RUN terraform --version

ARG VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/insekticid/k8s-upgrade"
