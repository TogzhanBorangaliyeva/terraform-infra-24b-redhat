resource "aws_iam_role" "grafana_role" {
  name               = "grafana-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::539247466139:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/91DEC1CCDF8A562681F7A8EAE98BD76A"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-1.amazonaws.com/id/91DEC1CCDF8A562681F7A8EAE98BD76A:sub" = "system:serviceaccount:monitoring:grafana"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "grafana_role_policy" {
  name = "policy_name"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:GetSecretValue",
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:us-east-1:539247466139:secret:grafana_secrets-ttgkeA"
    },
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_grafana_role_policy" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_role_policy.arn
}