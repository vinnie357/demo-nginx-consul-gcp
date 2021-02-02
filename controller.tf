# Setup Onboarding scripts
data "template_file" "nginx-controller_onboard" {
  template = file("${path.module}/templates/nginx-controller/startup.sh.tpl")

  vars = {
    bucket         = var.nginx-controllerBucket
    serviceAccount = google_service_account.nginx-controller-sa.email
    secretName     = google_secret_manager_secret.nginx-controller-secret.secret_id
  }
}

# template
resource "google_compute_instance_template" "nginx-controller-template" {
  name_prefix = "nginx-controller-template-"
  description = "This template is used to create runner server instances."

  instance_description = "nginx-controller"
  machine_type         = "n1-standard-8"
  can_ip_forward       = false
  tags                 = ["nginx-controller"]
  disk {
    source_image = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
    auto_delete  = true
    boot         = true
    type         = "pd-ssd"
    disk_size_gb = 40
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_network_sub.id
    access_config {
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  metadata = {
    ssh-keys       = "${var.adminAccount}:${var.nginxPublicKey},demoadmin:${tls_private_key.ansible-sa-key.public_key_pem}"
    startup-script = data.template_file.nginx-controller_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/nginx-controller/shutdown.sh")}"
  }
  service_account {
    email  = google_service_account.nginx-controller-sa.email
    scopes = ["cloud-platform"]
  }
}

# instance group

resource "google_compute_instance_group_manager" "nginx-controller-group" {
  // depends_on         = [google_container_cluster.primary]
  name               = "${var.projectPrefix}-nginx-controller-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-nginx-controller"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.nginx-controller-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
