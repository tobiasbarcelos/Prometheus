resource "null_resource" "install_softwares" {
  depends_on = [azurerm_linux_virtual_machine.main]

  provisioner "file" {
    source      = "${path.module}/install_prometheus.sh"
    destination = "/tmp/install_prometheus.sh"
  
    connection {
     type     = "ssh"
     host     = "172.174.37.110"       # IP público da VM
     user     = var.admin_username
     password = var.admin_password
     timeout  = "2m"
    }
  }  

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = "172.174.37.110"
      user     = var.admin_username
      password = var.admin_password
    }

    inline = [
      "ls -l /tmp/install_prometheus.sh",
      "chmod +x /tmp/install_prometheus.sh",
      "ls -l /tmp/install_prometheus.sh",
      "sudo /bin/bash /tmp/install_prometheus.sh"
    ]
  }
}
