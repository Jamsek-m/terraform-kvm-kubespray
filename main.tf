#================================
# Local variables
#================================

# Local variables used in many resources #
locals {
  config   = (var.config_type == "yaml") ? yamldecode(file(pathexpand(var.config_path))) : null
  internal = {
    is_bridge = (local.config.cluster.network.mode == "bridge")
    vm_types  = {
      load_balancer = "lb"
      master        = "master"
      worker        = "worker"
    }
  }
}


#=====================================================================================
# Providers
#=====================================================================================

provider "libvirt" {
  alias = "localhost"
  uri = "qemu:///system"
}


#======================================================================================
# Modules
#======================================================================================

module "main_localhost" {

  source = "./modules/main"
  count  = var.config_type == "yaml" ? 1 : 0

  # General
  action = var.action

  # Libvirt
  libvirt_resource_pool_location = "/var/lib/libvirt/pools/"

  # General
  cluster_name                             = try(local.config.cluster.name, null)
  cluster_nodeTemplate_user                = try(local.config.cluster.nodeTemplate.user, null)
  cluster_nodeTemplate_ssh_privateKeyPath  = try(local.config.cluster.nodeTemplate.ssh.privateKeyPath, null)
  cluster_nodeTemplate_ssh_addToKnownHosts = try(local.config.cluster.nodeTemplate.ssh.addToKnownHosts, null)
  cluster_nodeTemplate_image_distro        = try(local.config.cluster.nodeTemplate.image.distro, null)
  cluster_nodeTemplate_image_source        = try(local.config.cluster.nodeTemplate.image.source, null)
  cluster_nodeTemplate_networkInterface    = try(local.config.cluster.nodeTemplate.networkInterface, null)
  cluster_nodeTemplate_updateOnBoot        = try(local.config.cluster.nodeTemplate.updateOnBoot, null)

  # Network configuration
  cluster_network_mode    = try(local.config.cluster.network.mode, null)
  cluster_network_cidr    = try(local.config.cluster.network.cidr, null)
  cluster_network_gateway = try(local.config.cluster.network.gateway, null)
  cluster_network_bridge  = try(local.config.cluster.network.bridge, null)
  cluster_network_dns     = try(local.config.cluster.network.dns, null)

  # HAProxy load balancer VMs parameters
  cluster_nodes_loadBalancer_vip             = try(local.config.cluster.nodes.loadBalancer.vip, null)
  cluster_nodes_loadBalancer_default_cpu     = try(local.config.cluster.nodes.loadBalancer.default.cpu, null)
  cluster_nodes_loadBalancer_default_ram     = try(local.config.cluster.nodes.loadBalancer.default.ram, null)
  cluster_nodes_loadBalancer_default_storage = try(local.config.cluster.nodes.loadBalancer.default.storage, null)
  cluster_nodes_loadBalancer_instances       = [for node in try(local.config.cluster.nodes.loadBalancer.instances, []) : node if try(node.server, null) == "localhost"]

  # Master node VMs parameters
  cluster_nodes_master_default_cpu     = try(local.config.cluster.nodes.master.default.cpu, null)
  cluster_nodes_master_default_ram     = try(local.config.cluster.nodes.master.default.ram, null)
  cluster_nodes_master_default_storage = try(local.config.cluster.nodes.master.default.storage, null)
  cluster_nodes_master_instances       = [for node in try(local.config.cluster.nodes.master.instances, []) : node if try(node.server, null) == "localhost"]

  # Worker node VMs parameters
  cluster_nodes_worker_default_cpu     = try(local.config.cluster.nodes.worker.default.cpu, null)
  cluster_nodes_worker_default_ram     = try(local.config.cluster.nodes.worker.default.ram, null)
  cluster_nodes_worker_default_storage = try(local.config.cluster.nodes.worker.default.storage, null)
  cluster_nodes_worker_default_label   = try(local.config.cluster.nodes.worker.default.label, null)
  cluster_nodes_worker_instances       = [for node in try(local.config.cluster.nodes.worker.instances, []) : node if try(node.server, null) == "localhost"]

  # Kubernetes & Kubespray
  kubernetes_version                     = try(local.config.kubernetes.version, null)
  kubernetes_networkPlugin               = try(local.config.kubernetes.networkPlugin, null)
  kubernetes_dnsMode                     = try(local.config.kubernetes.dnsMode, null)
  kubernetes_kubespray_url               = try(local.config.kubernetes.kubespray.url, null)
  kubernetes_kubespray_version           = try(local.config.kubernetes.kubespray.version, null)
  kubernetes_kubespray_addons_enabled    = false # try(local.config.kubernetes.kubespray.addons.enabled, null)
  kubernetes_kubespray_addons_configPath = ""    # try(local.config.kubernetes.kubespray.addons.configPath, null)
  kubernetes_other_copyKubeconfig        = try(local.config.kubernetes.other.copyKubeconfig, null)

  # Other
  internal = local.internal

  providers = {
    libvirt = libvirt.localhost
  }

}

module "main_tf_localhost" {

  source = "./modules/main"
  count  = var.config_type == "tf" ? 1 : 0

  # General
  action = var.action

  # Libvirt
  libvirt_resource_pool_location = "/var/lib/libvirt/pools/"

  # Global VM configuration
  cluster_name                             = var.cluster_name
  cluster_nodeTemplate_user                = var.cluster_nodeTemplate_user
  cluster_nodeTemplate_ssh_privateKeyPath  = var.cluster_nodeTemplate_ssh_privateKeyPath
  cluster_nodeTemplate_ssh_addToKnownHosts = var.cluster_nodeTemplate_ssh_addToKnownHosts
  cluster_nodeTemplate_image_distro        = var.cluster_nodeTemplate_image_distro
  cluster_nodeTemplate_image_source        = var.cluster_nodeTemplate_image_source
  cluster_nodeTemplate_networkInterface    = var.cluster_nodeTemplate_networkInterface
  cluster_nodeTemplate_updateOnBoot        = var.cluster_nodeTemplate_updateOnBoot

  # Network configuration
  cluster_network_mode    = var.cluster_network_mode
  cluster_network_cidr    = var.cluster_network_cidr
  cluster_network_gateway = var.cluster_network_gateway
  cluster_network_bridge  = var.cluster_network_bridge
  cluster_network_dns     = var.cluster_network_dns

  # HAProxy load balancer VMs parameters
  cluster_nodes_loadBalancer_vip             = var.cluster_nodes_loadBalancer_vip
  cluster_nodes_loadBalancer_default_cpu     = var.cluster_nodes_loadBalancer_default_cpu
  cluster_nodes_loadBalancer_default_ram     = var.cluster_nodes_loadBalancer_default_ram
  cluster_nodes_loadBalancer_default_storage = var.cluster_nodes_loadBalancer_default_storage
  cluster_nodes_loadBalancer_instances       = var.cluster_nodes_loadBalancer_instances

  # Master node VMs parameters
  cluster_nodes_master_default_cpu     = var.cluster_nodes_master_default_cpu
  cluster_nodes_master_default_ram     = var.cluster_nodes_master_default_ram
  cluster_nodes_master_default_storage = var.cluster_nodes_master_default_storage
  cluster_nodes_master_instances       = var.cluster_nodes_master_instances

  # Worker node VMs parameters
  cluster_nodes_worker_default_cpu     = var.cluster_nodes_worker_default_cpu
  cluster_nodes_worker_default_ram     = var.cluster_nodes_worker_default_ram
  cluster_nodes_worker_default_storage = var.cluster_nodes_worker_default_storage
  cluster_nodes_worker_default_label   = var.cluster_nodes_worker_default_label
  cluster_nodes_worker_instances       = var.cluster_nodes_worker_instances

  # Kubernetes & Kubespray
  kubernetes_version                     = var.kubernetes_version
  kubernetes_networkPlugin               = var.kubernetes_networkPlugin
  kubernetes_dnsMode                     = var.kubernetes_dnsMode
  kubernetes_kubespray_url               = var.kubernetes_kubespray_url
  kubernetes_kubespray_version           = var.kubernetes_kubespray_version
  kubernetes_kubespray_addons_enabled    = false # var.kubernetes_kubespray_addons_enabled
  kubernetes_kubespray_addons_configPath = ""    # var.kubernetes_kubespray_addons_configPath
  kubernetes_other_copyKubeconfig        = var.kubernetes_other_copyKubeconfig

  # Other
  internal = local.internal

  providers = {
    libvirt = libvirt.localhost
  }

}

#================================
# Cluster
#================================


# Configures k8s cluster using Kubespray #
module "k8s_cluster" {
  source = "./modules/cluster"

  action = var.action

  # VM variables #
  vm_user              = try(local.config.cluster.nodeTemplate.user, null)
  vm_ssh_private_key   = pathexpand(try(local.config.cluster.nodeTemplate.ssh.privateKeyPath, null))
  vm_distro            = try(local.config.cluster.nodeTemplate.image.distro, null)
  vm_network_interface = local.internal.is_bridge ? local.config.cluster.network.bridge : var.cluster_nodeTemplate_networkInterface

  worker_node_label = try(local.config.cluster.nodes.worker.default.label, null)
  lb_vip            = try(local.config.cluster.nodes.loadBalancer.vip, null)
  lb_nodes          = [for node in flatten([module.main_localhost.0.nodes]) : node if node.type == local.internal.vm_types.load_balancer]
  master_nodes      = [for node in flatten([module.main_localhost.0.nodes]) : node if node.type == local.internal.vm_types.master]
  worker_nodes      = [for node in flatten([module.main_localhost.0.nodes]) : node if node.type == local.internal.vm_types.worker]

  # Kubernetes & Kubespray
  kubernetes_version                     = try(local.config.kubernetes.version, null)
  kubernetes_networkPlugin               = try(local.config.kubernetes.networkPlugin, null)
  kubernetes_dnsMode                     = try(local.config.kubernetes.dnsMode, null)
  kubernetes_kubespray_url               = try(local.config.kubernetes.kubespray.url, null)
  kubernetes_kubespray_version           = try(local.config.kubernetes.kubespray.version, null)
  kubernetes_kubespray_addons_enabled    = false # try(local.config.kubernetes.kubespray.addons.enabled, null)
  kubernetes_kubespray_addons_configPath = ""    # try(local.config.kubernetes.kubespray.addons.configPath, null)
  kubernetes_other_copyKubeconfig        = try(local.config.kubernetes.other.copyKubeconfig, null)

  # Other #
  #k8s_dashboard_rbac_enabled = var.k8s_dashboard_rbac_enabled
  #k8s_dashboard_rbac_user    = var.k8s_dashboard_rbac_user

  # K8s cluster creation depends on all VM modules #
  depends_on = [
    module.main_localhost,
    module.main_tf_localhost,
  ]
}