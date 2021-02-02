# template
# Setup Onboarding scripts
data "template_file" "nginx_onboard" {
  template = file("${path.module}/templates/nginx/startup.sh.tpl")

  vars = {
    controllerAddress = "12134"
    secretName        = google_secret_manager_secret.nginx-secret.secret_id
  }
}
resource "google_compute_instance_template" "nginx-template" {
  name_prefix = "nginx-template-"
  description = "This template is used to create runner server instances."

  instance_description = "nginx-lb"
  machine_type         = "n1-standard-2"
  can_ip_forward       = false
  tags                 = ["lb"]
  disk {
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
    ssh-keys       = "${var.adminAccount}:${var.nginxPublicKey},demoadmin:${tls_private_key.ansible-sa-key.public_key_pem}"
    startup-script = data.template_file.nginx_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/nginx/shutdown.sh")}"
  }
  service_account {
    email  = google_service_account.gce-nginx-sa.email
    scopes = ["cloud-platform"]
  }
}
resource "google_compute_instance_template" "nginx-ctlb-template" {
  name_prefix = "nginx-ctlb-template-"
  description = "This template is used to create runner server instances."

  instance_description = "nginx-ctl-lb"
  machine_type         = "n1-standard-2"
  can_ip_forward       = false
  tags                 = ["ctl-lb"]
  disk {
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
    ssh-keys       = "${var.adminAccount}:${var.nginxPublicKey}"
    startup-script = data.template_file.nginx_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/nginx/shutdown.sh")}"
  }
  service_account {
    email  = google_service_account.gce-nginx-sa.email
    scopes = ["cloud-platform"]
  }
}
# instance group 0
resource "google_compute_instance_group_manager" "nginx-group" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-nginx-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-nginx-lb"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.nginx-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# instance group 1
resource "google_compute_instance_group_manager" "nginx-group-1" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-nginx-instance-group-manager-1"
  base_instance_name = "${var.projectPrefix}-nginx-ctl"
  zone               = "${var.gcpRegion}-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.nginx-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# instance group 0
resource "google_compute_instance_group_manager" "nginx--ctlb-group" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-nginx-ctlb-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-nginx-lb"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.nginx-ctlb-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# instance group 1
resource "google_compute_instance_group_manager" "nginx-ctlb-group-1" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-nginx-ctlb-instance-group-manager-1"
  base_instance_name = "${var.projectPrefix}-nginx-ctl"
  zone               = "${var.gcpRegion}-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.nginx-ctlb-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
