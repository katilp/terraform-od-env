resource "kubernetes_persistent_volume" "nfs" {
  metadata {
    name = "nfs"
  }
  spec {
    capacity = {
      storage = "100Gi"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      nfs {
        server = kubernetes_service.nfs-server-service.spec[0].cluster_ip
        path = "/"     
      }
    }
  }
}

# resource "kubernetes_persistent_volume_claim" "nfs-claim" {
#   metadata {
#     name = "nfs"
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     storage_class_name = " "

#     resources {
#       requests = {
#         storage = "100Gi"
#       }
#     }

#   }
# }