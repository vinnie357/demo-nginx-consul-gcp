# admin
variable adminSrcAddr {
  description = "admin src address in cidr"
}
variable adminAccount {
  description = "admin account"
}
variable adminPass {
  description = "admin password"
}
# GKE
variable projectPrefix {
  description = "prefix for resources"
}
variable gcpZone {
  description = "zone where gke is deployed"
}
variable gcpRegion {
  description = "region where gke is deployed"
}
variable gcpProjectId {
  description = "gcp project id"
}
#https://cloud.google.com/kubernetes-engine/docs/release-notes-regular
variable gkeVersion {
  default = "1.16.3-gke.5"
}

variable podCidr {
  description = "k8s pod cidr"
  default     = "10.56.0.0/14"
}

# consul

# nginx
variable nginxKey {
  description = "key for nginxplus"
}
variable nginxCert {
  description = "cert for nginxplus"
}
# controller
variable controllerLicense {
  description = "license for controller"
  default     = "none"
}