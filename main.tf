resource "azurerm_resource_group" "qt" {
  name     = "terraform"
  location = "East US"
}
resource "azurerm_public_ip" "newip" {
  name                = "acceptanceTestPublicIp"
  resource_group_name = azurerm_resource_group.qt.name
  location            = azurerm_resource_group.qt.location
  allocation_method   = "Dynamic"
  depends_on = [
    azurerm_resource_group.qt
  ]
}
resource "azurerm_virtual_network" "main" {
  name                = "vmlog"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.qt.location
  resource_group_name = azurerm_resource_group.qt.name
  depends_on = [
    azurerm_resource_group.qt
  ]
}

resource "azurerm_subnet" "main" {
  name                 = "net"
  resource_group_name  = azurerm_resource_group.qt.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.1.0/24"]
  depends_on = [
    azurerm_virtual_network.main
  ]
}

resource "azurerm_network_interface" "main" {
  name                = "vp"
  location            = azurerm_resource_group.qt.location
  resource_group_name = azurerm_resource_group.qt.name


  ip_configuration {
    name                          = "test"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.newip.id
  }
}
resource "azurerm_network_security_group" "main" {
  name                = "SecurityGroup"
  location            = azurerm_resource_group.qt.location
  resource_group_name = azurerm_resource_group.qt.name
  depends_on = [
    azurerm_subnet.main
  ]
}
resource "azurerm_network_security_rule" "rule" {
  name                        = "ssh"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.qt.name
  network_security_group_name = azurerm_network_security_group.main.name
}
resource "azurerm_linux_virtual_machine" "main" {
  name                = "ansiblevm"
  location            = azurerm_resource_group.qt.location
  resource_group_name = azurerm_resource_group.qt.name
  size                = "Standard_B1s"
  admin_username      = "playbook"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  admin_ssh_key {
    username   = "playbool"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_resource_group.qt
  ]
}

