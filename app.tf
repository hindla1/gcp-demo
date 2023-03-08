resource "google_compute_instance" "app-server" {
  name         = "app-server"
  machine_type = var.machine_type
  zone         = var.zone


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "app"
      }
    }
  }
  network_interface {
      network = google_compute_network.my-vpc.id
      subnetwork = google_compute_subnetwork.my-private-subnet.id
  }

}

