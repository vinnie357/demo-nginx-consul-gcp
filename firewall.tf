# firewall
resource google_compute_firewall default-allow-internal {
  name    = "${var.projectPrefix}default-allow-internal-${random_pet.buildSuffix.id}"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  priority = "65534"

  source_ranges = ["10.0.10.0/24"]
}

# mgmt
resource google_compute_firewall mgmt {
  name    = "${var.projectPrefix}mgmt-firewall${random_pet.buildSuffix.id}"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "80"]
  }

  source_ranges = var.adminSrcAddr
}