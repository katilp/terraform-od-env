# CMS Open data environment setup through Terraform (WIP)

This is work in progress to set up the CMS open data environment for GCP through [Terraform](https://www.terraform.io/) CLI.

The manual environment setup is documented in
- the CMS Open data workshop [slides](https://indico.cern.ch/event/882586/contributions/4042623/attachments/2114732/3557845/Open_Data_on_Kubernetes.pdf)
- in the cloud computing [tutorial](https://cms-opendata-workshop.github.io/workshop-lesson-kubernetes/)

## Setup through the Google cloud shell


[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/katilp/terraform-od-env.git)

Login with your GCP credentials and confirm the repository. Define the project in the cloud shell

```
gcloud config set project cms-opendata
```
The provisioning of of the Kubernetes cluster is taken care in the `provision-gke-cluster` directory.

Initialise Terraform, check and apply the configurations:

  ```
  cd provision-gke-cluster
  terraform init
  terraform plan 
  terraform apply
  ```

To be able to use kubectl commands in the cloud shell, get credentials to the newly created cluster:

  ```
  gcloud container clusters get-credentials cms-opendata-gke --zone europe-west6-a --project cms-opendata
  ```

While in principle the disk could be created at this stage, in practice, it has to be done separately, by hand. Otherwise the deployments trying to access that disk fail. Creat the disk in the cloud shell:

  ```
  gcloud compute disks create --size=100GB --zone=europe-west6-a gce-nfs-disk
  ```

The kubernetes resources are managed separately in the `manage-k8s-resources` directory. Change the user name in `kubernetes.tf` before applying.

  ```
  cd ../manage-k8s-resources
  terraform init
  terraform plan
  terraform apply
  ```
  
The persistent volume claim needs to be done separately in the cloud shell:

  ```
  kubectl apply -n argo -f pvc.yaml
  ```

This is because Terraform does not accept an empty string for the storage class name and assigns it to standard. Standard storage classes cannot be `ReadWriteMany`.

To test, install argo and run the test workflow:
 
  ```
  cd ../test
  ./argo-install.sh
  argo submit -n argo argo-wf-volume.yaml
  argo list -n argo
  ```
  
Check the pod name in the `argo list -n argo` command output and see if the test file appears in the pod.

  ```
  kubectl logs pod/test-hostpath-XXXXX  -n argo main
  ```
   
To clean up, delete the resources in the directories in which Terraform commands were submitted:

  ```
  cd ../manage-k8s-resources
  terraform destroy
  cd ../provision-gke-cluster
  terraform destroy
  ```
  
The persistent volume claim and the disk need to be deleted separately from the gcloud CLI or the GPC console GUI.   

  
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

Initialise Terraform, check and apply the configurations:

  ```
  cd terraform-od-env/provision-gke-cluster
  terraform init
  terraform plan 
  terraform apply
  ```
  
  The GKE resources can be accessed and monitored through the GPC console web GUI, or on the cloud shell which opens from the web GUI after having done
  
  ```
  gcloud container clusters get-credentials cms-opendata-gke --zone europe-west6-a --project cms-opendata
  ```
  
  or locally after having configured kubectl with
  
  ``` 
  gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
  ```

Add the disk manually with

  ```
  gcloud compute disks create --size=100GB --zone=europe-west6-a gce-nfs-disk
  ```

The kubernetes resources are managed separately in the `manage-k8s-resources` directory. Chage the user name in `kubernetes.tf` before applying.

  ```
  cd ../manage-k8s-resources
  terraform init
  terraform plan
  terraform apply
  ```
  
Create the persistent volume claim needs to be done separately from the local terminal or in the cloud shell:

  ```
  kubectl apply -n argo -f pvc.yaml
  ```
  
Do the testing as indicated above.  

To clean up, delete the resources in the directories in which Terraform commands were submitted:

  ```
  cd ../manage-k8s-resources
  terraform destroy
  cd ../provision-gke-cluster
  terraform destroy
  ```
  
The persistent volume claim and the disk need to be deleted separately from the gcloud CLI or the GPC console GUI.   
  
  
