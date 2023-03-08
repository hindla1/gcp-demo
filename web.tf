resource "google_compute_instance" "web" {
  name         = "web"
  machine_type = var.machine_type
  zone         = var.zone


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "web"
      }
    }
  }
  network_interface {
      network = google_compute_network.my-vpc.id
      subnetwork = google_compute_subnetwork.my-pub-subnet.id
      access_config {} 
  }

   metadata_startup_script = <<EOF
   #!/bin/bash
   apt update -y
   apt install apache2 -y
   echo "<h2>Welcome to Apache Webserver !!!</h2>" > /var/www/html/index.html
   systemctl restart apache2
   EOF


}



resource "google_compute_instance_group" "webservers" {
  name        = "demo-webservers"
  description = "demo instance group"
  instances = [
    google_compute_instance.web.id
  ]

  named_port {
    name = "http"
    port = "80"
  }
}

