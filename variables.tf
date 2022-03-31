# Cluster Name
variable "cluster_name" {
  description = "Cluster EKS name."
  type        = string
}

# VPC
variable "vpc_id" {
  description = "CIDR block to vpc1."
}

# Subnets
variable "subnet_ids" {
  description = "List of IDs subnets"
  type        = list(string)
}

# EKS Cluster Version
variable "cluster_version" {
  description = "Kubernetes version supported by EKS"
}

# Control Plane Logging
variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "authenticator", "controllerManager", "scheduler"]
}

# Role used in cluster
variable "aws_role_eks" {
  description = "Role to be added to cluster"
  type        = list(string)
  default     = []
}

# Role name - EKS
variable "aws_role_eks_cluster" {
  description = "Role to be added to cluster"
  type        = string
  default     = "EKSRole"
}

# Policy name - EKS
variable "eks_worker_policy" {
  description = "Role to be added to cluster"
  type        = string
  default     = "EKS-Worker-Policy"
}

# Additional security groups
variable "additional_security_group_ids" {
  description = "A list of additional security group ids to attach to cluster."
  type        = list(string)
  default     = []
}

# Additional Cluster - SG
variable "eks_cluster_sg" {
  description = "A list of additional security group ids to attach to cluster."
  type        = string
  default     = "eks-cluster-sg"
}

# Security Group used in EKS Nodes
variable "eks_nodes_sg" {
  description = "Security group to attach in nodes."
  type        = string
  default     = "eks-nodes-sg"
}

# Tags
variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}

variable "eks_nodes_sg_description" {
  type    = string
  default = "Allow traffic to EKS nodes"
}

variable "eks_cluster_sg_description" {
  type    = string
  default = "Allow traffic to EKS"
}

variable "eks_worker_role_name" {
  type    = string
  default = "EKS-Worker-Role"
}

variable "eks_worker_policy_description" {
  type    = string
  default = "EKS Worker Policy"
}

variable "eks_cluster_role_description" {
  type    = string
  default = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
}

variable "eks_nodes_role_description" {
  type = string
  default = "Allows EC2 instances to call AWS services on your behalf."
}

variable "eks_cluster_role_self_description" {
  type = string
  default = "EKS Nodes SG - Secondary"
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}