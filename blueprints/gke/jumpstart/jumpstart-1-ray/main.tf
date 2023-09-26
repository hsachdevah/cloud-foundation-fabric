/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  wl_templates = [
    for f in fileset(local.wl_templates_path, "[0-9]*yaml") :
    "${local.wl_templates_path}/${f}"
  ]
  wl_templates_path = (
    var.templates_path == null
    ? "${path.module}/k8s-manifests"
    : pathexpand(var.templates_path)
  )
}

data "google_client_config" "identity" {
  count = var.credentials_config.fleet_host != null ? 1 : 0
}

data "google_project" "project" {
  project_id = var.project_id
}

# provider "kubernetes" {
#   config_path = (
#     var.credentials_config.kubeconfig == null
#     ? null
#     : pathexpand(var.credentials_config.kubeconfig.path)
#   )
#   config_context = try(
#     var.credentials_config.kubeconfig.context, null
#   )
#   host = (
#     var.credentials_config.fleet_host == null
#     ? null
#     : var.credentials_config.fleet_host
#   )
#   token = try(data.google_client_config.identity.0.access_token, null)
# }

resource "kubernetes_namespace" "ray" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kuberay-operator" {
  name       = "kuberay-operator"
  repository = "https://ray-project.github.io/kuberay-helm/"
  chart      = "kuberay-operator"
}

# resource "kubernetes_manifest" "default" {
#   for_each = toset(local.wl_templates)
#   manifest = yamldecode(templatefile(each.value, {
#     # image              = var.image
#     namespace          = kubernetes_namespace.default.metadata.0.name
#     # statefulset_config = var.statefulset_config
#   }))
#   # dynamic "wait" {
#   #   for_each = strcontains(each.key, "statefulset") ? [""] : []
#   #   content {
#   #     fields = {
#   #       "status.readyReplicas" = var.statefulset_config.replicas
#   #     }
#   #   }
#   # }
#   timeouts {
#     create = "30m"
#   }
# }

# resource "kubernetes_manifest" "cluster-start" {
#   manifest = yamldecode(templatefile("${local.wl_templates_path}/start-cluster.yaml", {
#     image     = var.image
#     namespace = kubernetes_namespace.default.metadata.0.name
#     nodes = [
#       for i in range(var.statefulset_config.replicas) :
#       "redis-${i}.redis-cluster.${var.namespace}.svc.cluster.local"
#     ]
#   }))
#   field_manager {
#     force_conflicts = true
#   }
#   depends_on = [kubernetes_manifest.default]
# }
