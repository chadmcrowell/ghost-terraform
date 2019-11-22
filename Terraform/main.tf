resource "azurerm_resource_group" "test" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}
# Create virtual network
resource "azurerm_virtual_network" "ghost_vnet" {
    name = "labVNET"
    address_space = ["10.0.0.0/16"]
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
}

# Create subnet
resource "azurerm_subnet" "ghost_subnet" {
    name = "ghostSUBNET"
    resource_group_name = "${var.resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.ghost_vnet.name}"
    address_prefix = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "ghost_pip" {
    name = "labPIP"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    public_ip_address_allocation = "dynamic"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "ghost_nsg" {
    name = "ghostNSG"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    security_rule {
        name = "SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}
# Create network interface
resource "azurerm_network_interface" "ghost_nic" {
    name = "ghostNIC"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    network_security_group_id = "${azurerm_network_security_group.ghost_nsg.id}"
    ip_configuration {
        name = "ghostNicConfiguration"
        subnet_id = "${azurerm_subnet.ghost_subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.ghost_pip.id}"
    }
}
# Create virtual machine
resource "azurerm_virtual_machine" "ghost_vm" {
    name = "ghostVM"
    location = "${local.location}"
    resource_group_name = "${local.resource_group_name}"
    network_interface_ids = ["${azurerm_network_interface.lab_nic.id}"]
    vm_size = "Standard_B1ms"
    storage_os_disk {
        name = "ghostVMOSDISK"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04.0-LTS"
        version = "latest"
    }
    os_profile {
        computer_name = "ghostvm"
        admin_username = "ghostvmadmin"
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/chad/.ssh/authorized_keys"
            key_data = "__storagekey__"
        }
    }
}