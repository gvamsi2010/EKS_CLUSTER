# flux.tf

# Provider configuration
# In flux.tf


provider "flux" {
  kubernetes = {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
  
  git = {
    url = "https://github.com/gvamsi2010/Flux-test.git"
    branch = "main"
    http = {
      username = "gvamsi2010"
      password = var.github_token
    }
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [aws_eks_cluster.cluster]
  path      = "clusters/eks-01"
}

# Create flux-system namespace
resource "kubernetes_namespace" "flux_system" {
  depends_on = [aws_eks_cluster.cluster]
  
  metadata {
    name = "flux-system"
  }
}
