resource "google_compute_firewall" "kbn_firewall" {
  name    = "kbn-firewall"
  network = google_compute_network.kbn_vpc.name

  # allow tcp/ssh from anywhere
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # allow tcp/http on Kibana's dev server port
  allow {
    protocol = "tcp"
    ports    = [var.kibana_server_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kbn-server"]
}
