resource "kubernetes_service" "nfs-server-service" {
  metadata {
    name = "nfs-server-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      role = "nfs-server"
    }
    
    port {
      port = 2049
      name = "nfs"
    }

    port {
      port = 20048
      name = "mountd"
    }

    port {
      port = 111
      name = "rpcbind"
    }

  }
}