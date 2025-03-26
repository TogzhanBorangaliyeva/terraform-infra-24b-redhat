### IAM role for service account.
data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
  name               = "karpenter-controller"
}

resource "aws_iam_policy" "karpenter_controller" {
  name = "KarpenterController"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "iam:PassRole",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet"
        ]
        Resource = "*"
        Sid      = "Karpenter"
      },
      {
        Effect = "Allow"
        Action = "ec2:TerminateInstances"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/Name" = "*karpenter*"
          }
        }
        Resource = "*"
        Sid      = "ConditionalEC2Termination"
      },
      {
        Effect   = "Allow"
        Action   = "pricing:GetProducts"
        Resource = "*"
        Sid      = "PricingAnalyst"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "aws_iam_role_policy_attachment" "karpenter_attach_eks_worker_policies" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = [aws_iam_role.karpenter_controller.name]
}

resource "aws_iam_role_policy_attachment" "karpenter_attach_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = [aws_iam_role.karpenter_controller.name]
}

resource "aws_iam_role_policy_attachment" "karpenter_attach_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = [aws_iam_role.karpenter_controller.name]
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile"
  role = aws_iam_role.karpenter_controller.name  # Ensure correct role var.worker_node_iam_role 
}
