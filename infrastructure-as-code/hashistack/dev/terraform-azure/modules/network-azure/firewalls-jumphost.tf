resource "azurerm_network_security_group" "jumphost" {
  # Drata: Configure [azurerm_network_security_group.tags] to ensure that organization-wide tagging conventions are followed.
  name                = "${var.environment_name}-jumphost"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "jumphost_ssh" {
  name                        = "${var.environment_name}-jumphost-ssh"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.jumphost.name}"

  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  # Drata: Ensure that [azurerm_network_security_rule.source_address_prefix] is explicitly defined and narrowly scoped to only allow traffic from trusted sources
  source_port_range          = "*"
  destination_port_range     = "22"
  destination_address_prefix = "*"
}
