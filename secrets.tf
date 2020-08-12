# enable secret manager api
#resource google_project_service secretmanager {
#  service  = "secretmanager.googleapis.com"
#}
# nginx
# create secret
resource google_secret_manager_secret nginx-secret {
  secret_id = "nginx-secret"
  labels = {
    label = "nginx"
  }

  replication {
    automatic = true
  }
}
# create secret version
resource google_secret_manager_secret_version nginx-secret {
  depends_on  = [google_secret_manager_secret.nginx-secret]
  secret      = google_secret_manager_secret.nginx-secret.id
  secret_data = <<-EOF
  {
  "cert":"${var.nginxCert}",
  "key": "${var.nginxKey}"
  }
  EOF
}
# controller
# create secret
resource google_secret_manager_secret controller-secret {
  secret_id = "controller-secret"
  labels = {
    label = "controller"
  }

  replication {
    automatic = true
  }
}
# create secret version
resource google_secret_manager_secret_version controller-secret {
  depends_on  = [google_secret_manager_secret.controller-secret]
  secret      = google_secret_manager_secret.controller-secret.id
  secret_data = <<-EOF
  {
  "license": ${jsonencode(var.controllerLicense)}
  }
  EOF
}