variable "gcp_project" {
    description = "GCP Project"
}
variable "gcp_region" {
    description = "GCP Region"
}
variable "gcp_zone" {
    description = "GCP Zone"
}
variable "nodes" {
    description = "Number of instances"
}
variable "owner" {
    description = "Owner name for tagging and access"
    default = "dcanadillas"
}
variable "machine" {
    description = "GCP instance type"
    default = "n1-standard-2"
}
variable "cluster" {
    description = "Cluster name for the nodes"
}