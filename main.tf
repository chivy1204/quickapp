terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "2.46.0"
        }
    }
}
provider "azurerm" {
    features {
      
    }
}
data "template_file" "install-init" {
    template = file("install.sh")
}
resource "azurerm_resource_group" "quickapp" {
    name = "quickapp-resource"
    location = "Korea Central"
}
resource "azurerm_virtual_network" "quickapp" {
    name = "quickapp-network"
    resource_group_name = azurerm_resource_group.quickapp.name
    location = azurerm_resource_group.quickapp.location
    address_space = [ "10.0.0.0/16" ]
}
resource "azurerm_subnet" "quickapp" {
    name = "internal"
    resource_group_name = azurerm_resource_group.quickapp.name
    virtual_network_name = azurerm_virtual_network.quickapp.name
    address_prefixes = [ "10.0.2.0/24" ]
}
resource "azurerm_public_ip" "apptest" {
    name = "apptest"
    location = azurerm_resource_group.quickapp.location
    resource_group_name = azurerm_resource_group.quickapp.name
    allocation_method = "Static"
    idle_timeout_in_minutes = 30
    ip_version = "IPv4"
    domain_name_label = "vync"
}
resource "azurerm_public_ip" "frontend" {
    name = "frontend"
    location = azurerm_resource_group.quickapp.location
    resource_group_name = azurerm_resource_group.quickapp.name
    allocation_method = "Static"
    idle_timeout_in_minutes = 30
    ip_version = "IPv4"
    domain_name_label = "frontendquickapp"
}
resource "azurerm_network_security_group" "quickapp" {
    name = "apptest"
    location = azurerm_resource_group.quickapp.location
    resource_group_name = azurerm_resource_group.quickapp.name
}
resource "azurerm_network_security_rule" "SSH" {
    name = "SSH"
    priority = 300
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.quickapp.name
    network_security_group_name = azurerm_network_security_group.quickapp.name
}
resource "azurerm_network_security_rule" "HTTPS" {
    name = "HTTPS"
    priority = 320
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.quickapp.name
    network_security_group_name = azurerm_network_security_group.quickapp.name
}
resource "azurerm_network_security_rule" "HTTP" {
    name = "HTTP"
    priority = 340
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.quickapp.name
    network_security_group_name = azurerm_network_security_group.quickapp.name
}
resource "azurerm_network_interface" "quickapp" {
    name = "quickapp-interface"
    location = azurerm_resource_group.quickapp.location
    resource_group_name = azurerm_resource_group.quickapp.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.quickapp.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.apptest.id
    }
}
resource "azurerm_network_interface" "frontend" {
    name = "frontend-interface"
    location = azurerm_resource_group.quickapp.location
    resource_group_name = azurerm_resource_group.quickapp.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.quickapp.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.apptest.id
    }
}
resource "azurerm_network_interface_security_group_association" "quickapp" {
    network_interface_id = azurerm_network_interface.quickapp.id
    network_security_group_id = azurerm_network_security_group.quickapp.id
}
resource "azurerm_linux_virtual_machine" "frontend" {
    name = "frontend"
    resource_group_name = azurerm_resource_group.quickapp.name
    location = azurerm_resource_group.quickapp.location
    size = "Standard_B1ls"
    admin_username = "vync"
    network_interface_ids = [ azurerm_network_interface.frontend.id ]
    admin_ssh_key {
        username = "vync"
        public_key = file("~/.ssh/id_rsa.pub")
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }
    custom_data = base64encode(data.template_file.install-init.rendered)
}
resource "azurerm_linux_virtual_machine" "apptest" {
    name = "apptest"
    resource_group_name = azurerm_resource_group.quickapp.name
    location = azurerm_resource_group.quickapp.location
    size = "Standard_B1ms"
    admin_username = "vync"
    network_interface_ids = [ azurerm_network_interface.quickapp.id ]
    admin_ssh_key {
        username = "vync"
        public_key = file("~/.ssh/id_rsa.pub")
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }
    # custom_data = base64encode(data.template_file.cloud-init.rendered)
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "vync"
            private_key = "${file("~/.ssh/id_rsa")}"
            host = "${azurerm_public_ip.apptest.ip_address}"
            timeout = "2m"
        }
        inline = [
            "sudo apt-get update",
            "sudo apt install nginx -y",
            "sudo apt install unzip",
            "sudo snap install core; sudo snap refresh core",
            "sudo snap install dotnet-sdk --classic --channel=5.0",
            "sudo snap alias dotnet-sdk.dotnet dotnet",
            "sudo snap install --classic certbot",
            "sudo certbot run -n --nginx --agree-tos -d vync.koreacentral.cloudapp.azure.com -m chivy1204@gmail.com --redirect",
            "sudo rm /etc/nginx/sites-available/default",
            "sudo chmod 777 /etc/nginx/sites-available/",
            "sudo chmod 777 /etc/systemd/system/",
            "cd /home/vync",
            "mkdir backend",
            "cd backend",
            "mkdir hello",
            "sudo dotnet dev-certs https --clean",
            "sudo dotnet dev-certs https",
        ]
    }
    provisioner "file" {
        connection {
            type = "ssh"
            user = "vync"
            private_key = "${file("~/.ssh/id_rsa")}"
            host = "${azurerm_public_ip.apptest.ip_address}"
            timeout = "2m"
        }
        source = "default"
        destination = "/etc/nginx/sites-available/default"
    }
    provisioner "file" {
        connection {
            type = "ssh"
            user = "vync"
            private_key = "${file("~/.ssh/id_rsa")}"
            host = "${azurerm_public_ip.apptest.ip_address}"
            timeout = "2m"
        }
        source = "quickapp.service"
        destination = "/etc/systemd/system/quickapp.service"
    }
}
data "azurerm_public_ip" "ip" {
    name = azurerm_public_ip.apptest.name
    resource_group_name = azurerm_linux_virtual_machine.apptest.resource_group_name
    depends_on = [
      azurerm_linux_virtual_machine.apptest
    ]
}
data "azurerm_public_ip" "frontend" {
    name = azurerm_public_ip.frontend.name
    resource_group_name = azurerm_linux_virtual_machine.frontend.resource_group_name
    depends_on = [
      azurerm_linux_virtual_machine.frontend
    ]
}
output "host" {
    value = data.azurerm_public_ip.ip.ip_address
}
output "frontend" {
    value = data.azurerm_public_ip.frontend.ip_address
}