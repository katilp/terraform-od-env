resource "kubernetes_pod" "pv-pod" {
  metadata {
    name      = "pv-pod"
    namespace = var.namespace
  }

  spec {

    volume {
      name      = "task-pv-storage"
      persistent_volume_claim {
        claim_name = "nfs"  
      }
    }

    container {
      image         = "busybox"
      name          = "pv-container"
      command       = ["tail", "-f", "/dev/null"]
      volume_mount {
        mount_path  = "/mnt/data"
        name        = "task-pv-storage"
      }
    }
  }
}