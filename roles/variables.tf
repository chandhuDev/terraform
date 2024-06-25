variable "test-role" {
  type = "string"
  description = "provides the role for the production environment which is read only"
}

variable "dev-role" {
  type = "string"
  description = "provides the role for the staging environment which is write and read"
}

variable "eks-name" {
  type = "string"
}