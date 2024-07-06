output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks-name" {
  value = aws_eks_cluster.eks.name
}

output "eks-version" {
  value = aws_eks_cluster.eks.version
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.eks.certificate_authority[0].data
# }