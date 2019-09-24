variable "region" {
  default = "us-central1-a"
}

variable "credentialPath" {
  default = "~/fleet-geode-253715-f0eedc401dd2.json"
}

variable "clusterName" {
  default = "newsfeed"
}

variable "clusterVersion" {
  default = "1.14.3-gke.11"
}

variable "projectName" {
  default = "fleet-geode-253715"
}

variable "nodePoolSize" {
  default = "n1-standard-1"
}
