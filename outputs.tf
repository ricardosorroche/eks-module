output "eks_cluster" {
  value = aws_eks_cluster.this
}

output "cluster_role" {
  value = aws_iam_role.eks_cluster
}

output "worker_role" {
  value = aws_iam_role.eks_nodes
}

output "cluster_sg" {
  value = aws_security_group.eks_cluster_sg
}

output "nodes_sg" {
  value = aws_security_group.eks_nodes_sg
}