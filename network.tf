


# networks
# vpc
resource "google_compute_network" "vpc_network" {
  name                    = "${var.projectPrefix}terraform-network-mgmt-${random_pet.buildSuffix.id}"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}
resource "google_compute_subnetwork" "vpc_network_sub" {
  name          = "${var.projectPrefix}mgmt-sub-${random_pet.buildSuffix.id}"
  ip_cidr_range = "10.0.10.0/24"
  region        = var.gcpRegion
  network       = google_compute_network.vpc_network.self_link

}
