resource "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids         = var.public_subnet_ids
    security_group_ids = [aws_security_group.eks_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name                 = "${var.cluster_name}-role"
  max_session_duration = var.max_session_duration_cluster
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_security_group" "eks_sg" {
  name   = "eks-cluster-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.cluster_name}-sg"
  }
}

resource "aws_security_group_rule" "control_plane_ingress" {
  description              = "Allow worker nodes to communicate with the EKS API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.node_sg.id

  depends_on = [
    aws_security_group.node_sg,
  ]
}

resource "aws_security_group_rule" "control_plane_egress_all" {
  description              = "Allow control plane to communicate with nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.node_sg.id

  depends_on = [
    aws_security_group.node_sg,
  ]
}

resource "aws_security_group_rule" "control_plane_egress" {
  description              = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.node_sg.id

  depends_on = [
    aws_security_group.node_sg,
  ]
}