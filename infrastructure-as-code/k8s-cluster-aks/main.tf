terraform {
  required_version = ">= 0.11.11"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

provider "vault" {
  address = "${var.vault_addr}"
}

data "vault_generic_secret" "azure_credentials" {
  path = "secret/${var.vault_user}/azure/credentials"
}

provider "azurerm" {
  subscription_id = "${data.vault_generic_secret.azure_credentials.data["subscription_id"]}"
  tenant_id       = "${data.vault_generic_secret.azure_credentials.data["tenant_id"]}"
  client_id       = "${data.vault_generic_secret.azure_credentials.data["client_id"]}"
  client_secret   = "${data.vault_generic_secret.azure_credentials.data["client_secret"]}"
}

# Azure Resource Group
resource "azurerm_resource_group" "k8sexample" {
  name     = "${var.resource_group_name}"
  location = "${var.azure_location}"
}

# Azure Container Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "k8sexample" { # Drata:  should be set to any of azure, calico, cilium # Drata:  should be set to any of stable, rapid, patch
  # Drata: Set [azurerm_kubernetes_cluster.role_based_access_control_enabled] to true to configure resource authentication using role based access control (RBAC). RBAC allows for more granularity when defining permissions for users and workloads that can access a resource. Set [microsoft_container_service.managed_clusters.disable_local_accounts] to true to restrict access to your cluster through local admin accounts. If configuring this setting on an existing cluster, be sure to rotate cluster certificates to revoke any certificates that previously authenticated users may have had access to
  # Drata: Ensure that [azurerm_kubernetes_cluster.api_server_authorized_ip_ranges] is explicitly defined and narrowly scoped to only allow trusted sources to access AKS Control Plane
  name = "${var.vault_user}-k8sexample-cluster"
  location = "${azurerm_resource_group.k8sexample.location}"
  resource_group_name = "${azurerm_resource_group.k8sexample.name}"
  dns_prefix = "${var.dns_prefix}"
  kubernetes_version = "${var.k8s_version}"

  linux_profile {
    admin_username = "${var.admin_user}"
    ssh_key {
      key_data = "${chomp(tls_private_key.ssh_key.public_key_openssh)}"
    }
  }

  agent_pool_profile {
    name       = "${var.agent_pool_name}"
    count      =  "${var.agent_count}"
    os_type    = "${var.os_type}"
    os_disk_size_gb = "${var.os_disk_size}"
    vm_size    = "${var.vm_size}"
  }

  service_principal {
    client_id     = "${data.vault_generic_secret.azure_credentials.data["client_id"]}"
    client_secret = "${data.vault_generic_secret.azure_credentials.data["client_secret"]}"
  }

  tags {
    Environment = "${var.environment}"
  }
}
