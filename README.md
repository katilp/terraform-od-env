# CMS Open data environment setup through Terraform (WIP)

This is work in progress to set up the CMS open data environment for GCP through [Terraform](https://www.terraform.io/) CLI.

The manual environment setup is documented in
- the CMS Open data workshop [slides](https://indico.cern.ch/event/882586/contributions/4042623/attachments/2114732/3557845/Open_Data_on_Kubernetes.pdf)
- in the cloud computing [tutorial](https://cms-opendata-workshop.github.io/workshop-lesson-kubernetes/)

## Setup through the Google cloud shell


[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/katilp/terraform-od-env.git)



## Setup from a local terminal

### Install

Install Terraform (see the details in [the Terraform guide](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)):

  ```
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform
  terraform -help
  terraform -install-autocomplete
  exec bash # restart shell
  ```
### Cloud authentication

Prerequisites for GCP (see the details in [the Terraform tutorial](https://learn.hashicorp.com/tutorials/terraform/gke?in=terraform/kubernetes#prerequisites)):

- install gcloud (https://cloud.google.com/sdk/docs/quickstart#deb)
  ```
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  sudo apt-get install apt-transport-https ca-certificates gnupg
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  sudo apt-get update && sudo apt-get install google-cloud-sdk
  ```
- initialise with your GCP credentials `gcloud init --console-only` and choose the project
- authenticate `gcloud auth application-default login`

### Apply the setup
Download the Terraform configuration files for CMS OD environment from this repository

  ```
  git clone git@github.com:katilp/terraform-od-env.git
  ```

The provisioning of of the Kubernetes cluster and the disk is taken care in the `provision-gke-cluster` directory. Before applying the Terraform configurations, two APIs need to be enabled on [the GPC console](https://console.cloud.google.com/):
- Compute engine API
- Kubernetes engine API (this has a cost of 0.10USD/hour)

Initialise Terraform, check and apply the configurations.

  ```
  cd terraform-od-env/provision-gke-cluster
  terraform init
  terraform plan 
  terraform apply
  ```
  
  The GKE resources can be monitored through the GPC console web GUI, or on the cloud shell which opens from the web GUI after having done
  ```
  gcloud container clusters get-credentials cms-opendata-gke --zone europe-west6-a --project cms-opendata
  ```
  or locally after having configured kubectl with
  ``` 
  gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
  ```

The kubernetes resources are managed separately in the `manage-k8s-resources` directory.

  ```
  cd ../manage-k8s-resources
  terraform init
  terraform plan
  terraform apply
  ```
  
For the moment, the resource deployment fails, and the `nfs-server` workload needs to deleted manually.

Normally, to clean up, one would the delete the resources in the both directories

  ```
  terraform destroy
  cd ../provision-gke-cluster
  terraform destroy
  ```
  
