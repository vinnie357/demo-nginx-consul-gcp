# admin
variable "adminSrcAddr" {
  description = "admin src address in cidr"
}
variable "adminAccount" {
  description = "admin account"
}
variable "adminPass" {
  description = "admin password"
}
# GKE
variable "projectPrefix" {
  description = "prefix for resources"
}
variable "gcpZone" {
  description = "zone where gke is deployed"
}
variable "gcpRegion" {
  description = "region where gke is deployed"
}
variable "gcpProjectId" {
  description = "gcp project id"
}
#https://cloud.google.com/kubernetes-engine/docs/release-notes-regular
#https://cloud.google.com/kubernetes-engine/versioning-and-upgrades
#gcloud container get-server-config --region us-east1
variable "gkeVersion" {
  default = "1.18.14-gke.1200"
}

variable "podCidr" {
  description = "k8s pod cidr"
  default     = "10.56.0.0/14"
}

# consul

# nginx
variable "nginxKey" {
  description = "key for nginxplus"
}
variable "nginxCert" {
  description = "cert for nginxplus"
}
variable "nginxPublicKey" {
  description = "admin public key"
}
# controller
variable "controllerLicense" {
  description = "license for controller"
  default     = "none"
}
variable "nginx-controllerBucket" {
  description = "name of controller installer bucket"
  default     = "none"
}
variable "controllerAccount" {
  description = "name of controller admin account"
  default     = "admin@nginx-gcp.internal"
}
variable "controllerPass" {
  description = "pass of controller admin account"
  default     = "admin123!"
}
variable "dbPass" {
  description = "pass of controller admin account"
  default     = "naaspassword"
}
variable "dbUser" {
  description = "pass of controller admin account"
  default     = "naas"
}