

resource "tls_private_key" "helm" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "ECDSA"

  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 1200000

  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}


resource "tls_cert_request" "helm" {
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.helm.private_key_pem}"

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

resource "tls_locally_signed_cert" "helm" {
  cert_request_pem   = "${tls_cert_request.helm.cert_request_pem}"
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 120000000

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}



provider "helm" {
    install_tiller  = "true"
    tiller_image = "gcr.io/kubernetes-helm/tiller:v2.12.3"
    service_account = "tiller"
    enable_tls = true
    automount_service_account_token = "true"
    client_key = "${tls_private_key.helm.private_key_pem}"
    client_certificate = "${tls_locally_signed_cert.helm.cert_pem}"
    ca_certificate = "${tls_self_signed_cert.ca.cert_pem}"

    kubernetes {
        config_context = "minikube"
    }
}

resource "helm_release" "example" {
  name       = "my-redis-release"
  repository = "stable"
  chart      = "redis"
  version    = "6.0.1"

  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set_string {
    name  = "service.annotations.prometheus\\.io/port"
    value = "9127"
  }
}
