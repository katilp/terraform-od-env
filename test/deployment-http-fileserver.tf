terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../manage-k8s-resources/terraform.tfstate"
  }
}

resource "kubernetes_config_map" "basic-config" {
  metadata {
    name        = "basic-config"
    namespace   = var.namespace
  }

  data = {
    "my_config_file.yml" = "nginx-basic.conf"
  }

}

resource "kubernetes_deployment" "http-fileserver" {

  metadata {
    name = "http-fileserver"
    namespace = var.namespace
    labels = {
      service = "http-fileserver"
    }
  }
  spec {
    replicas = 1
    strategy = {}
    selector {
      match_labels = {
        service = "http-fileserver"
      }
    }
    template {
      metadata {
        labels = {
          service = "http_fileserver"
        }
      }
      spec {
        container {
          image = "nginx"
          name = "file-storage-container"
          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html"
            name = "volume-output"
          }

          volume_mount {
            mount_path = "/etc/nginx/conf.d"
            name = "basic-config"
          }

        }

        volume {
          persistent_volume_claim {
            claim_name = "nfs"
          }
          name = "volume-output"
        }

        volume {
          config_map {
            claim_name = "basic-config"
          }
          name = "basic-config"
        }

      }
    }
  }
}
