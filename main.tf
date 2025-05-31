terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0.0"
    }   
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#data "azurerm_resource_group" "storage_rg" {
  #name = var.storage_resource_group_name
#}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnet0001" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_network_security_group" "nsg_name" {
  name                = var.nsg_name
  resource_group_name = var.nsg_resource_group_name
  location            = var.location
}

resource "azurerm_network_security_rule" "allow_internet" {
  name                        = "allow_internet"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80,443"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  network_security_group_name = var.nsg_name
  resource_group_name         = var.nsg_resource_group_name

  depends_on = [ azurerm_network_security_group.nsg_name]
}

resource "azurerm_network_security_rule" "allow_Prometheus" {
  name                        = "Allow_Prometheus" 
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9090"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = var.nsg_name
  resource_group_name         = var.nsg_resource_group_name

  depends_on = [ azurerm_network_security_group.nsg_name]
}

resource "azurerm_network_security_rule" "allow_grafana" {
  name                        = "allow_Grafana"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = var.nsg_name
  resource_group_name         = var.nsg_resource_group_name

  depends_on = [ azurerm_network_security_group.nsg_name]
}

resource "azurerm_network_security_rule" "allow_nodeexporter" {
  name                        = "allow_NodeExporter"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = var.nsg_name
  resource_group_name         = var.nsg_resource_group_name

  depends_on = [ azurerm_network_security_group.nsg_name]
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "201.10.36.42"
  destination_address_prefix  = "*"
  network_security_group_name = var.nsg_name
  resource_group_name         = var.nsg_resource_group_name

  depends_on = [ azurerm_network_security_group.nsg_name]
}

resource "azurerm_public_ip" "vm_ip" {
  name                = "${var.vm_name}-public-ip-terraform"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet0001.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_name.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.vm_size

  provision_vm_agent = true
  allow_extension_operations = true

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = "Dev"
    Automacao   = "Terraform"
    Product     = "Prometeus"
    Ea          = "CloudLab"
    Created-by  = "tobias.barcelos"
    DisableAzurePolicy = "true"
  }
}