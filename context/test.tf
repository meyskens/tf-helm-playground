provider "helm" {
    service_account = "tiller"
    namespace = "kube-system"
    kubernetes {
        insecure = true
        host = "https://192.168.99.100:8443"
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
