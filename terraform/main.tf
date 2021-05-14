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
resource "azurerm_resource_group" "quickapp" {
    name = "quickapp-resource"
    location = "East Asia"
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
    domain_name_label = "apptestquickapp"
}

data "template_file" "install-init" {
    template = file("install.sh")
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
resource "azurerm_network_interface_security_group_association" "quickapp" {
    network_interface_id = azurerm_network_interface.quickapp.id
    network_security_group_id = azurerm_network_security_group.quickapp.id
}
resource "azurerm_linux_virtual_machine" "apptest" {
    name = "apptest"
    resource_group_name = azurerm_resource_group.quickapp.name
    location = azurerm_resource_group.quickapp.location
    size = "Standard_B1ls"
    admin_username = "vync"
    disable_password_authentication = false
    admin_password = "$StrongPassword_12$"
    network_interface_ids = [ azurerm_network_interface.quickapp.id ]
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
