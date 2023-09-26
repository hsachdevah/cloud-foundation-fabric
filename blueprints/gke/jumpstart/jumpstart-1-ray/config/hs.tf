
# Specify either fleet_host OR kubeconfig 
credentials_config = {
  fleet_host = "https://connectgateway.googleapis.com/v1/projects/494975018659/locations/global/gkeMemberships/ray-cluster",
  # kubeconfig = {
  #   context = "gke_ai-on-gke-jss-sandbox_europe-west2_ray-cluster",
  #   path    = "~/.kube/config"
  # }
}
project_id   = "ai-on-gke-jss-sandbox"
cluster_name = "ray-cluster"
region       = "europe-west2"
