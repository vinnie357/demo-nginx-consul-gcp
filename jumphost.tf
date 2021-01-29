#jumphost
resource "google_compute_instance_template" "jumphost-template" {
  name_prefix          = "jumphost-template-"
  description          = "This template is used to create runner server instances."
  tags                 = ["jumphost-demo"]
  instance_description = "jumphost"
  machine_type         = "n1-standard-2"
  can_ip_forward       = false

  disk {
    #source_image = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
    source_image = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
    auto_delete  = true
    boot         = true
    type         = "pd-ssd"
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
    ssh-keys = "${var.adminAccount}:${var.nginxPublicKey},demoadmin:${tls_private_key.ansible-sa-key.public_key_pem}"
    #startup-script = data.template_file.jumphost_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/jumphost/shutdown.sh")}"
  }
  service_account {
    #email = google_service_account.jumphost-sa.email
    scopes = ["cloud-platform"]
  }
}

# instance group 0
resource "google_compute_instance_group_manager" "jumphost-group" {
  // depends_on         = [google_container_cluster.primary]
  name               = "${var.projectPrefix}-jumphost-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-jumphost"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.jumphost-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
