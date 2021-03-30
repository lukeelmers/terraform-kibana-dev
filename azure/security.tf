resource "azurerm_network_security_group" "kbn_nsg" {
  name                = "kbn_nsg"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.kbn_rg.name

  # allow tcp/ssh from anywhere
  security_rule {
    name                       = "allow-ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }

  # allow tcp/http on Kibana's dev server port
  security_rule {
    name                       = "allow-http"
    priority                   = 999
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = var.kibana_server_port
    destination_address_prefix = "*"
  }

  # allow outbound access from anywhere
  security_rule {
    name                       = "allow-outbound"
    priority                   = 998
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
}
