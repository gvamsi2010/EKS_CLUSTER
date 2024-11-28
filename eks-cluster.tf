# create a eks cluster with in vpc with 3 nodes of t2 medium type and 3 different availability zones with 3 different subnets also create a security group for the eks cluster and attach it to the eks cluster attach a eks  role to eks cluster and ec2 role to ec2 instances in the cluster

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policy_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_policy_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_policy_3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}



# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = "eks-cluster-01"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]

}



# Get current caller identity
data "aws_caller_identity" "current" {}

# Add RBAC cluster role binding
resource "kubernetes_cluster_role_binding" "cluster_admin" {
  metadata {
    name = "cluster-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = data.aws_caller_identity.current.user_id
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [aws_eks_cluster.cluster]
}


# Enable VPC CNI add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_cluster.cluster]
}
