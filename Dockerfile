FROM hashicorp/terraform:0.14.3

RUN apk -Uuv add ca-certificates openssl groff less git bash wget make jq curl unzip sed

WORKDIR /app

ENTRYPOINT ["/bin/terraform"]

CMD ["--help"]

ENV USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"

RUN curl -L -o kubectl-cert-manager.tar.gz https://github.com/jetstack/cert-manager/releases/download/v1.1.0/kubectl-cert_manager-linux-amd64.tar.gz
RUN tar xzf kubectl-cert-manager.tar.gz
RUN mv kubectl-cert_manager /usr/local/bin

ENV RKE_VERSION=v1.2.3
RUN wget -q --user-agent="${USER_AGENT}" https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_linux-amd64
RUN chmod +x rke_linux-amd64
RUN mv rke_linux-amd64 /usr/bin/rke

# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.17.0"

RUN wget -q --user-agent="${USER_AGENT}" https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/bin/helm \
    && chmod +x /usr/bin/helm

ENV HELM_VERSION3="v3.4.2"

RUN wget -q --user-agent="${USER_AGENT}" https://get.helm.sh/helm-${HELM_VERSION3}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/bin/helm3 \
    && chmod +x /usr/bin/helm3
RUN helm3 plugin install https://github.com/helm/helm-2to3

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
