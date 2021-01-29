# template

# Setup Onboarding scripts
data "template_file" "consul_onboard" {
  template = file("${path.module}/templates/consul/startup.sh.tpl")

  vars = {
    CONSUL_VERSION = "1.7.2"
    zone           = var.gcpZone
    project        = var.gcpProjectId
  }
}

resource "google_compute_instance_template" "consul-template" {
  name_prefix          = "consul-template-"
  description          = "This template is used to create runner server instances."
  tags                 = ["consul-demo"]
  instance_description = "consul"
  machine_type         = "n1-standard-4"
  can_ip_forward       = false

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
    ssh-keys       = "${var.adminAccount}:${var.nginxPublicKey},demoadmin:${tls_private_key.ansible-sa-key.public_key_pem}"
    startup-script = data.template_file.consul_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/consul/shutdown.sh")}"
  }
  service_account {
    #email = google_service_account.consul-sa.email
    scopes = ["cloud-platform"]
  }
}

# instance group 0

resource "google_compute_instance_group_manager" "consul-group" {
  // depends_on         = [google_container_cluster.primary]
  name               = "${var.projectPrefix}-consul-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-consul"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.consul-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}

# instance group 1
resource "google_compute_instance_group_manager" "consul-group-c" {
  // depends_on         = [google_container_cluster.primary]
  name               = "${var.projectPrefix}-consul-instance-group-manager-c"
  base_instance_name = "${var.projectPrefix}-consul"
  zone               = "${var.gcpRegion}-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.consul-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}