resource "aws_eks_cluster" "eks-cluster" {
  name     = "example-cluster"
  role_arn = aws_iam_role.eks-role.arn
  version  = "1.22"

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids = setunion(
      module.vpc.private_subnets,
      module.vpc.public_subnets
    )
  }

  depends_on = [aws_iam_role_policy_attachment.eks-role-AmazonEKSClusterPolicy]
}