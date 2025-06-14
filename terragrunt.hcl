terraform {
  source = "../VM"
}

inputs = {
  subscription_id           = "ID_SUBSCRIPTION"
  vnet_name                 = "dev-eastus-prometheus-vnet"
  subnet_name               = "subnet0001"
  resource_group_name       = "prd-eastus2-cloudops-computing-rg"
  location                  = "East US"
  nic_name                  = "vm-prometheus-dev-nic"
  nsg_name                  = "vm-prometheus-dev-nsg"
  nsg_resource_group_name   = "prd-eastus-cloudops-computing-rg"
  source_ip                 = "172.174.37.110"
  destination_ip            = "10.189.2.20"
  vm_name                   = "NOME DA VM"
  vm_size                   = "Standard_B2ms"
  admin_username            = "cloudops"
  admin_password            = "N9cuADD1hK47"
  disk_type                 = "StandardSSD_LRS"
}
