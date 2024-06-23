variable "eks-cluster-name" {
  type = string
}

variable "smn-instance-type" {
  type = string
}
variable "smn-node-image" {
  type = string
}
variable "eks-smn-security-group" {
  type = string
}
variable "subnet_ids" {
  type = map(string)
}