resource "google_compute_network" "kbn_vpc" {
  name                    = "kbn-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kbn_subnet" {
  name          = "kbn-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.kbn_vpc.id
}
