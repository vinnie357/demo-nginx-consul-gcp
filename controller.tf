# Setup Onboarding scripts
data template_file controller_onboard {
  template = file("${path.module}/scripts/controller/startup.sh.tpl")

  vars = {
    MYVAR = "12134"
  }
}

# template
resource google_compute_instance_template controller-template {
  name_prefix = "controller-template-"
  description = "This template is used to create runner server instances."

  instance_description = "controller"
  machine_type         = "n1-standard-8"
  can_ip_forward       = false

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
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
    startup-script = data.template_file.controller_onboard.rendered
    #shutdown-script = "${file("${path.module}/scripts/controller/shutdown.sh")}"
  }
  service_account {
    #email  = google_service_account.gce-controller-sa.email
    scopes = ["cloud-platform"]
  }
}

# instance group

resource google_compute_instance_group_manager controller-group {
  name               = "${var.projectPrefix}-controller-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-controller"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.controller-template.id
  }
  # wait for gke cluster
  timeouts {
    create = 10
  }
}