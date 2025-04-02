resource "aws_iam_role" "eks_worker_role" {
  name = "${var.eks_worker_node}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  depends_on = [
    aws_eks_cluster.eks_cluster,
  ]

}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_registry_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_instance_profile" "eks_worker_profile" {
  name = "eks-worker-instance-profile"
  role = aws_iam_role.eks_worker_role.name
}

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "eks_node_template" {
  name          = var.eks_worker_node
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.node_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    /etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_worker_profile.name
  }

}

resource "aws_autoscaling_group" "eks_asg" {
  name                = "${var.cluster_name}-nodes"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.public_subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      spot_max_price                           = var.spot_max_price
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_node_template.id
        version            = "$Latest"
      }
    }
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

}

resource "aws_security_group" "node_sg" {
  name_prefix = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

}

# for hpa, opening port to collect metrics
resource "aws_security_group_rule" "allow_metrics" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]  # Or restrict to control plane's CIDR block
}

resource "aws_security_group_rule" "node_self_ingress" {
  type                     = "ingress"
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "node_ingress" {
  type                     = "ingress"
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.eks_sg.id
}

# resource "aws_security_group_rule" "node_ingress_2" {
#   type                     = "ingress"
#   description              = "Allow pods running extension API servers on port 80 to receive communication from cluster control plane"
#   from_port                = 80
#   to_port                  = 80
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.node_sg.id
#   source_security_group_id = aws_security_group.eks_sg.id
# }

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "Allow SSH access to nodes"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker_nodes_egress_internet" {
  description       = "Allow worker nodes to access the internet"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node_ingress_8443" {
  type                     = "ingress"
  description              = "Allow webhook validation requests to ingress-nginx admission controller"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.eks_sg.id
}

resource "aws_security_group_rule" "node_ingress_udp_dns" {
  type                     = "ingress"
  description              = "Allow CoreDNS to resolve cluster services."
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_ports_ipv6" {
  type              = "ingress"
  description       = "Allow all traffic from my IPv6 for testing"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  ipv6_cidr_blocks  = ["2601:246:5400:ef60:78f3:b673:5b02:bc03/128"] # Replace with your IPv6
}

resource "aws_security_group_rule" "allow_port_9200" {
  type              = "ingress"
  description       = "Allow local machine access to Elasticsearch"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"] # Replace with your actual IP
}

resource "aws_security_group_rule" "allow_port_9300" {
  type              = "ingress"
  description       = "Allow inter-node communication for Elasticsearch"
  from_port         = 9300
  to_port           = 9300
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"] # Restrict this to your VPC CIDR for security
}

resource "aws_security_group_rule" "allow_port_3306" {
  type              = "ingress"
  description       = "RDS"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"] # Restrict this to your VPC CIDR for security
}