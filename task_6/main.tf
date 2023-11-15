provider "google" {
  project = "bamboo-creek-401412"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.wa-dareit-bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket" "wa-dareit-bucket" {
  name     = "wa-dareit-bucket"
  location = "US"
}

resource "google_compute_instance" "wa-vm" {
  name         = "wa-vm-tf"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["dareit"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        managed_by_terraform = "true"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

resource "google_sql_database" "database" {
  name     = "dareit"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name             = "dareit-instance"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }

  deletion_protection  = "true"
}

resource "google_sql_user" "users" {
  name     = "dareit_user"
  instance = google_sql_database_instance.instance.name
  password = "password123"
}