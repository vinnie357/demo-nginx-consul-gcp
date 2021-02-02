# template

# Setup Onboarding scripts
// data template_file storage_onboard {
//   template = file("${path.module}/templates/storage/startup.sh.tpl")

//   vars = {
//     storage_VERSION = "1.7.2"
//     zone           = var.gcpZone
//     project        = var.gcpProjectId
//   }
// }

resource "google_compute_instance_template" "storage-template" {
  name_prefix          = "storage-template-"
  description          = "This template is used to create runner server instances."
  tags                 = ["storage-demo"]
  instance_description = "storage"
  machine_type         = "n1-standard-2"
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
    #startup-script = data.template_file.storage_onboard.rendered
    #shutdown-script = "${file("${path.module}/templates/storage/shutdown.sh")}"
  }
  service_account {
    #email = google_service_account.storage-sa.email
    scopes = ["cloud-platform"]
  }
}

# instance group 0
resource "google_compute_instance_group_manager" "storage-group" {
  // depends_on         = [google_container_cluster.primary]
  name               = "${var.projectPrefix}-storage-instance-group-manager"
  base_instance_name = "${var.projectPrefix}-storage"
  zone               = var.gcpZone
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.storage-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
# instance group 0
resource "google_compute_instance_group_manager" "storage-group-1" {
  // depends_on         = [google_container_cluster.primary]
  name               = "${var.projectPrefix}-storage-instance-group-manager-c"
  base_instance_name = "${var.projectPrefix}-storage"
  zone               = "${var.gcpRegion}-c"
  target_size        = 1
  version {
    instance_template = google_compute_instance_template.storage-template.id
  }
  # wait for gke cluster
  timeouts {
    create = "15m"
  }
}
