resource "kubernetes_deployment" "deployment_nfs_server" {

    #"apiVersion" = "apps/v1"
    #"kind" = "Deployment"
    metadata {
      name = "nfs-server"
      namespace = var.namespace
    }
    spec {
      replicas = 1
      selector {
        match_labels = {
          role = "nfs-server"
        }
      }
      template {
        metadata {
          labels = {
            role = "nfs-server"
          }
        }
        spec {
          container {
            image = "gcr.io/google_containers/volume-nfs:0.8"
            name = "nfs-server"
            port {
              container_port = 2049
              name = "nfs"
            }

            port {
              container_port = 20048
              name = "mountd"
            }

            port {
              container_port = 111
              name = "rpcbind"
            }
  
            security_context {
              privileged = true
            }

            volume_mount {
              mount_path = "/exports"
              name = "mypvc"
            }

          }

          volume {
            gce_persistent_disk {
              fs_type = "ext4"
              pd_name = "gce-nfs-disk"
            }
            name = "mypvc"
            }

        }
      }
    }
}
