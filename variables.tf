variable "subscription_id" {
  description = "ID da assinatura do Azure"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Nome do grupo de recursos existente para VM"
}

#variable "storage_resource_group_name" {
  #type        = string
  #description = "Nome do Resource Group para a Storage Account"
#}

variable "vnet_name" {
  type = string
  description = "Nome da Vnet"
}

variable "vnet_address_space" {
  default = ["10.0.0.0/16"]
}

variable "subnet_name" {
  type        = string
  description = "Nome do subnet existente"
}
variable "address_prefixes" {
  description = "Lista de prefixos de rede"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
variable "location" {
  description = "Localização da infraestrutura"
  type        = string
}

variable "nic_name" {
  description = "Nome da NIC"
  type        = string
}

variable "nsg_name" {
  description = "Nome da NSG"
  type        = string
}

variable "nsg_resource_group_name" {
  description = "Nome do grupo de recursos onde a NSG está localizada"
  type        = string
}

variable "source_ip" {
  default = "4.157.241.174"
}

# variable "destination_ip" {
#   description = "IP de destino para a regra de segurança"
#   type        = string
#}

variable "vm_name" {
  description = "Nome da máquina virtual"
  type        = string
}

variable "vm_size" {
  description = "Tamanho da máquina virtual"
  type        = string
}

variable "admin_username" {
  description = "Usuário administrador"
  type        = string
}

variable "admin_password" {
  description = "Senha do administrador"
  type        = string
  sensitive   = true
}

variable "disk_type" {
  description = "Tipo de disco da VM"
  type        = string
}