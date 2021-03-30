resource "azurerm_virtual_network" "kbn_vnet" {
  name                = "kbn_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.kbn_rg.name
}

resource "azurerm_subnet" "kbn_subnet" {
  name                 = "kbn_subnet"
  resource_group_name  = azurerm_resource_group.kbn_rg.name
  virtual_network_name = azurerm_virtual_network.kbn_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "kbn_subnet_assoc" {
  subnet_id                 = azurerm_subnet.kbn_subnet.id
  network_security_group_id = azurerm_network_security_group.kbn_nsg.id
}

resource "azurerm_public_ip" "kbn_ip" {
  name                = "kbn_ip"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.kbn_rg.name
  domain_name_label   = "kibana-${uuid()}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "kbn_ni" {
  name                = "kbn_ni"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.kbn_rg.name

  ip_configuration {
    name                          = "kbn_ip_configuration"
    subnet_id                     = azurerm_subnet.kbn_subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.kbn_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "kbn_ni_assoc" {
  network_interface_id      = azurerm_network_interface.kbn_ni.id
  network_security_group_id = azurerm_network_security_group.kbn_nsg.id
}
