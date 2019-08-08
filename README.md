Available commands inside this docker image
-----------------------------------------------
 * helm 
 * terraform ( [with rke plugin](https://github.com/yamamoto-febc/terraform-provider-rke) )
 * rke
 * sed
 * less
 * git
 * wget
 * curl
 * make
 * jq
 * unzip
 
 Kubernetes upgrade via RKE
---------------------------
 * docker-compose run --rm --entrypoint sh rke 
 * rke up --config cluster.yml

  Example commands
 ------------------
  * helm init --upgrade --service-account tiller --kubeconfig kube_config_cluster.yml
  * helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
  * helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
  * helm repo update
 
  * helm install --name cert-manager --namespace kube-system stable/cert-manager --set ingressShim.extraArgs='{--default-issuer-name=letsencrypt-production,--default-issuer-kind=ClusterIssuer}' --kubeconfig kube_config_cluster.yml
 
  * helm upgrade cert-manager stable/cert-manager --kubeconfig kube_config_cluster.yml --namespace cert-manager --set ingressShim.defaultIssuerName=letsencrypt-staging --set ingressShim.defaultIssuerKind=ClusterIssuer
 
  * helm --kubeconfig kube_config_cluster.yml upgrade --namespace cattle-system rancher rancher-stable/rancher --set hostname=rancher.example.com --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=letsencrypt@example.com --set letsEncrypt.environment=production
 
  * kubectl --kubeconfig kube_config_cluster.yml -n cattle-system rollout status deploy/rancher
