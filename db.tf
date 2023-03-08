resource "google_sql_database_instance" "my-db" {
  name = "my-db"
  database_version = "POSTGRES_9_6"
  region = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}
