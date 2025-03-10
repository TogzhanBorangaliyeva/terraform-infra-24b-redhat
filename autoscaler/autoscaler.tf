resource "aws_autoscaling_group_tag" "eks_asg_tag-1" {
  autoscaling_group_name = var.asg_name

  tag {
    key   = "k8s.io/cluster-autoscaler/enabled"
    value = "true"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "eks_asg_tag-2" {
  autoscaling_group_name = var.asg_name

  tag {
    key   = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value = "true"
    propagate_at_launch = true
  }
}

# IAM role for Cluster Autoscaler with the same name
resource "aws_iam_role" "cluster_autoscaler" {
  name = var.role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${var.aws_oidc_provider_arn}"
      },
      "Effect": "Allow",
      "Condition": {
        "StringEquals": {
          "${var.aws_oidc_provider_arn}:sub" : "system:serviceaccount:kube-system:${var.cluster_autoscaler_service_account}"
        }
      }
    }
  ]
}
EOF
}

# Attaching policy
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name = var.policy_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeScheduledActions",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "eks:DescribeNodegroup",
        "eks:UpdateNodegroupConfig",
        "eks:UpdateNodegroupVersion",
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeRegions",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_cluster_autoscaler_policy" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

