# template
# Setup Onboarding scripts
data template_file nginx_onboard {
  template = file("${path.module}/scripts/nginx/startup.sh.tpl")

  vars = {
    MYVAR = "12134"
  }
}
resource google_compute_instance_template nginx-template {
  name_prefix = "nginx-template-"
  description = "This template is used to create runner server instances."

  instance_description = "nginx"
  machine_type         = "n1-standard-4"
  can_ip_forward       = false

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
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
    startup-script = data.template_file.nginx_onboard.rendered
    #shutdown-script = "${file("${path.module}/scripts/nginx/shutdown.sh")}"
  }
  service_account {
    #email  = google_service_account.gce-nginx-sa.email
    scopes = ["cloud-platform"]
  }
}

# instance group

resource google_compute_instance_group_manager nginx-group {
  name               = "${var.projectPrefix}-nginx-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-nginx"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.nginx-template.id
  }

}