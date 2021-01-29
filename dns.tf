# template
# Setup Onboarding scripts
resource "google_compute_instance_template" "dns-template" {
  name_prefix = "dns-template-"
  description = "This template is used to create runner server instances."

  instance_description = "internal-dns"
  machine_type         = "n1-standard-2"
  can_ip_forward       = false
  tags                 = ["internal-dns"]
  disk {
    source_image = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
    auto_delete  = true
    boot         = true
    type         = "pd-ssd"
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_network_sub.id
    // access_config {
    // }
  }
  lifecycle {
    create_before_destroy = true
  }
  metadata = {
    ssh-keys = "${var.adminAccount}:${var.nginxPublicKey},demoadmin:${tls_private_key.ansible-sa-key.public_key_pem}"
    #startup-script = data.template_file.nginx_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/nginx/shutdown.sh")}"
  }
  service_account {
    email  = google_service_account.gce-nginx-sa.email
    scopes = ["cloud-platform"]
  }
}


# instance group 1
resource "google_compute_instance_group_manager" "dns-group" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  name               = "${var.projectPrefix}-internal-dns-instance-group-manager-1"
  base_instance_name = "${var.projectPrefix}-internal-dns"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.dns-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}