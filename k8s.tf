# template
# Setup Onboarding scripts
data "template_file" "k8scontroller_onboard" {
  template = file("${path.module}/templates/k8scontroller/startup.sh.tpl")

  vars = {
    myvar = "12134"
  }
}
data "template_file" "k8sworker_onboard" {
  template = file("${path.module}/templates/k8sworker/startup.sh.tpl")

  vars = {
    myvar = "12134"
  }
}
resource "google_compute_instance_template" "k8scontroller-template" {
  name_prefix = "k8scontroller-template-"
  description = "This template is used to create runner server instances."

  instance_description = "k8s-controller-node"
  machine_type         = "n1-standard-2"
  can_ip_forward       = false
  tags                 = ["k8s-controller-node"]
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
    ssh-keys       = "${var.adminAccount}:${var.nginxPublicKey}"
    startup-script = data.template_file.nginx_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/nginx/shutdown.sh")}"
  }
  service_account {
    email  = google_service_account.gce-nginx-sa.email
    scopes = ["cloud-platform"]
  }
}
resource "google_compute_instance_template" "k8sworker-template" {
  name_prefix = "k8sworker-template-"
  description = "This template is used to create runner server instances."

  instance_description = "k8s-worker-node"
  machine_type         = "n1-standard-2"
  can_ip_forward       = false
  tags                 = ["k8s-worker-node"]
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
    ssh-keys       = "${var.adminAccount}:${var.nginxPublicKey}"
    startup-script = data.template_file.nginx_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/nginx/shutdown.sh")}"
  }
  service_account {
    email  = google_service_account.gce-nginx-sa.email
    scopes = ["cloud-platform"]
  }
}
# k8scontroller group 0
resource "google_compute_instance_group_manager" "k8scontroller-group" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-k8scontroller-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-k8scontroller"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.k8scontroller-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# k8scontroller group 1
resource "google_compute_instance_group_manager" "k8scontroller-group-1" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-k8scontroller-instance-group-manager-1"
  base_instance_name = "${var.projectPrefix}-k8scontroller-c"
  zone               = "${var.gcpRegion}-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.k8scontroller-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# k8sworker group 0
resource "google_compute_instance_group_manager" "k8sworker-group" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-k8sworker-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-k8sworker"
  zone               = var.gcpZone
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.k8sworker-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# k8sworker group 1
resource "google_compute_instance_group_manager" "k8sworker-group-1" {
  // depends_on         = [google_container_cluster.primary, google_compute_instance_group_manager.controller-group]
  depends_on         = [google_compute_instance_group_manager.nginx-controller-group]
  name               = "${var.projectPrefix}-k8sworker-instance-group-manager-1"
  base_instance_name = "${var.projectPrefix}-k8sworker-c"
  zone               = "${var.gcpRegion}-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.k8sworker-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}