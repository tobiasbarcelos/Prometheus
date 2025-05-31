terraform {
  source = "../VM"
}

inputs = {
  subscription_id           = "e841f5a6-05d7-4814-988f-0c61b9703bb1"
  vnet_name                 = "dev-eastus-prometheus-vnet"
  subnet_name               = "subnet0001"
  resource_group_name       = "prd-eastus2-cloudops-computing-rg"
  location                  = "East US"
  nic_name                  = "vm-prometheus-dev-nic"
  nsg_name                  = "vm-prometheus-dev-nsg"
  nsg_resource_group_name   = "prd-eastus2-cloudops-computing-rg"
  source_ip                 = "172.174.37.110"
  destination_ip            = "10.189.2.20"
  vm_name                   = "vm-prometheus-dev"
  vm_size                   = "Standard_B2ms"
  admin_username            = "cloudops"
  admin_password            = "N9cuADD1hK47"
  disk_type                 = "StandardSSD_LRS"
}