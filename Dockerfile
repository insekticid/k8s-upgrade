FROM hashicorp/terraform:0.12.12

RUN apk -Uuv add ca-certificates openssl groff less git bash wget make jq curl unzip sed

WORKDIR /app

ENTRYPOINT ["/bin/terraform"]

CMD ["--help"]

ENV TERRAFORM_RKE_VERSION=0.14.1
ENV RKE_FILENAME=terraform-provider-rke_${TERRAFORM_RKE_VERSION}_linux-amd64.zip
ENV RKE_TERRAFORM_URL=https://github.com/yamamoto-febc/terraform-provider-rke/releases/download/${TERRAFORM_RKE_VERSION}/${RKE_FILENAME}

ENV RKE_TERRAFORM_SHA256SUM=

RUN echo "Install Terraform plugin from:" \
  && echo "${RKE_TERRAFORM_URL}"
RUN mkdir -p ~/.terraform.d/plugins/
RUN wget ${RKE_TERRAFORM_URL}
RUN unzip ${RKE_FILENAME} -d ~/.terraform.d/plugins/
RUN rm -f ${RKE_FILENAME}

ENV RKE_VERSION=v0.3.2
RUN wget -q https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_linux-amd64
RUN chmod +x rke_linux-amd64
RUN mv rke_linux-amd64 /usr/bin/rke

# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.15.2"

RUN wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/bin/helm \
    && chmod +x /usr/bin/helm

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
