data "tls_certificate" "eks-cluster" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

##
# Autoscaler policy
##
data "aws_iam_policy_document" "eks-cluster-autoscaler-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks-cluster-autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-autoscaler-assume-role-policy.json
  name               = "eks-cluster-autoscaler"
}

resource "aws_iam_policy" "eks-cluster-autoscaler" {
  name = "eks-cluster-autoscaler"

  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-autoscaler-attach" {
  role       = aws_iam_role.eks-cluster-autoscaler.name
  policy_arn = aws_iam_policy.eks-cluster-autoscaler.arn
}

output "eks-cluster-autoscaler-arn" {
  value = aws_iam_role.eks-cluster-autoscaler.arn
}

##
# Load balancer controller policy
##
data "aws_iam_policy_document" "aws-load-balancer-controller-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws-load-balancer-controller" {
  assume_role_policy = data.aws_iam_policy_document.aws-load-balancer-controller-assume-role-policy.json
  name               = "aws-load-balancer-controller"
}

resource "aws_iam_policy" "aws-load-balancer-controller-policy" {
  policy = file("./policies/AWSLoadBalancerControllerPolicy.json")
  name   = "AWSLoadBalancerControllerPolicy"
}

resource "aws_iam_role_policy_attachment" "aws-load-balancer-controller-attach" {
  role       = aws_iam_role.aws-load-balancer-controller.name
  policy_arn = aws_iam_policy.aws-load-balancer-controller-policy.arn
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws-load-balancer-controller.arn
}
