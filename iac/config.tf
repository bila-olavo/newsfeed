provider "google" {
  credentials = "${file("${var.credentialPath}")}"
  project     = "${var.projectName}"
  region      = "${var.region}"
}
