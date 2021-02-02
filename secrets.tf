# enable secret manager api
#resource google_project_service secretmanager {
#  service  = "secretmanager.googleapis.com"
#}
# nginx
# create secret
resource "google_secret_manager_secret" "nginx-secret" {
  secret_id = "nginx-secret"
  labels = {
    label = "nginx"
  }

  replication {
    automatic = true
  }
}
# create secret version
resource "google_secret_manager_secret_version" "nginx-secret" {
  depends_on  = [google_secret_manager_secret.nginx-secret]
  secret      = google_secret_manager_secret.nginx-secret.id
  secret_data = <<-EOF
  {
  "cert":"${var.nginxCert}",
  "key": "${var.nginxKey}",
  "cuser": "${var.controllerAccount}@${var.baseDomain}",
  "cpass": "${var.controllerPass}"
  }
  EOF
}
# controller
# create secret
resource "google_secret_manager_secret" "nginx-controller-secret" {
  secret_id = "nginx-controller-secret"
  labels = {
    label = "nginx-controller"
  }

  replication {
    automatic = true
  }
}
# create secret version
resource "google_secret_manager_secret_version" "nginx-controller-secret" {
  depends_on  = [google_secret_manager_secret.nginx-controller-secret]
  secret      = google_secret_manager_secret.nginx-controller-secret.id
  secret_data = <<-EOF
  {
  "license": ${jsonencode(var.controllerLicense)},
  "user": "${var.controllerAccount}@${var.baseDomain}",
  "pass": "${var.controllerPass}",
  "dbpass": "${var.dbPass}",
  "dbuser": "${var.dbUser}"
  }
  EOF
}
# ansible key
resource "tls_private_key" "ansible-sa-key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}
