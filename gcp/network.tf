resource "google_compute_network" "kbn_vpc" {
  name                    =  "${var.gcp_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kbn_subnet" {
  name          = "${var.gcp_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.kbn_vpc.id
}
