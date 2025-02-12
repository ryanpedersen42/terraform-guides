resource "azurerm_virtual_network" "main" {
  # Drata: Configure [azurerm_virtual_network.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "${var.environment_name}"
  address_space       = ["${var.network_cidr}"]
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}
