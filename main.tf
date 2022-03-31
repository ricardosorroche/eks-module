# aws_iam_role.eks_cluster:
resource "aws_iam_role" "eks_cluster" {
  name        = var.aws_role_eks_cluster
  description = var.eks_cluster_role_description

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

locals {
  policy_arn_prefix = "arn:aws:iam::aws:policy"
}

# aws_iam_role_policy_attachment.cluster:
resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# aws_iam_role_policy_attachment.service:
resource "aws_iam_role_policy_attachment" "service" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# aws_iam_role.eks_nodes:
resource "aws_iam_role" "eks_nodes" {
  name        = var.eks_worker_role_name
  description = var.eks_nodes_role_description

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = var.tags
}

# aws_iam_instance_profile.eks_nodes:
resource "aws_iam_instance_profile" "eks_nodes" {
  name = aws_iam_role.eks_nodes.name
  role = aws_iam_role.eks_nodes.name
}

# aws_iam_policy.eks_worker_policy:
resource "aws_iam_policy" "eks_worker_policy" {
  name        = var.eks_worker_policy
  description = var.eks_worker_policy_description

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:DescribeNetwork*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = var.tags
}

# aws_iam_role_policy_attachment.worker_policy:
resource "aws_iam_role_policy_attachment" "worker_policy" {
  policy_arn = aws_iam_policy.eks_worker_policy.arn
  role       = aws_iam_role.eks_nodes.name
}

# aws_iam_role_policy_attachment.worker_node_policy:
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

# aws_iam_role_policy_attachment.ecr_policy:
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# aws_security_group.eks_cluster_sg:
resource "aws_security_group" "eks_cluster_sg" {
  name        = var.eks_cluster_sg
  description = var.eks_cluster_sg_description
  vpc_id      = var.vpc_id
  tags = {
    Name = var.eks_cluster_sg
  }
}

# aws_security_group_rule.cluster_egress:
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
  description       = ""
}

# aws_security_group_rule.eks_cluster_sg_self:
resource "aws_security_group_rule" "eks_cluster_sg_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_cluster_sg.id
  description       = var.eks_cluster_role_self_description
}

# aws_security_group_rule.eks_cluster_sg_cluster:
resource "aws_security_group_rule" "eks_cluster_sg_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "EKS Nodes SG"
}

# aws_security_group.eks_nodes_sg:
resource "aws_security_group" "eks_nodes_sg" {
  name        = var.eks_nodes_sg
  description = var.eks_nodes_sg_description
  vpc_id      = var.vpc_id
  tags = {
    Name = var.eks_nodes_sg
  }
}

# aws_security_group_rule.nodes_egress:
resource "aws_security_group_rule" "nodes_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = ""
}

# aws_security_group_rule.eks_nodes_sg_self:
resource "aws_security_group_rule" "eks_nodes_sg_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "EKS Nodes SG"
}

# aws_security_group_rule.eks_nodes_sg_nodes:
resource "aws_security_group_rule" "eks_nodes_sg_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_nodes_sg.id
  description              = "EKS Cluster SG - Secondary"
}

# aws_eks_cluster.this:
resource "aws_eks_cluster" "this" {
  enabled_cluster_log_types = var.cluster_enabled_log_types
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_cluster.arn
  tags                      = var.tags
  version                   = var.cluster_version

  timeouts {}

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    public_access_cidrs     = []
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    subnet_ids              = var.subnet_ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }
}
