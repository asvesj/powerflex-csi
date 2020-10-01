#you need to modify the below details to reflect your environment
data "vsphere_datacenter" "dc" {
  name = "PowerFlex DC"
}
data "vsphere_datastore" "datastore" {
  name          = "K8s-Cluster"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_compute_cluster" "cluster" {
    name          = "PowerFlex Cluster"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "data_network_1" {
  name          = "PF_DATA1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "data_network_2" {
  name          = "PF_DATA2"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_virtual_machine" "template" {
  name          = "CentOS-7-Template"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "rancher" {
    name             = "Rancher-190"
    folder           = "Kubernetes"
    resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    firmware         = "${data.vsphere_virtual_machine.template.firmware}"
    num_cpus 	     = 8
    memory   	     = 16384
    guest_id 	     = "${data.vsphere_virtual_machine.template.guest_id}"
    network_interface {
        network_id   = "${data.vsphere_network.network.id}"
        adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
	}
    disk {
        label            = "disk0"
        size             = "100"
        eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
        thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    }
    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
    clone {
	template_uuid = "${data.vsphere_virtual_machine.template.id}"
	customize {
	  linux_options {
	   host_name = "Rancher-190"
	   domain    = "test.lab"
        }
        network_interface {
	   ipv4_address = "10.10.10.190"
	   ipv4_netmask = 24
	}
        ipv4_gateway 	= "10.10.10.1"
	dns_server_list = ["8.8.8.8", "8.8.4.4"]
	}   
    }
	provisioner "file" {
	    connection {
	       host	= "${vsphere_virtual_machine.rancher.default_ip_address}"
	       type	= "ssh"
	       #modify the username of your virtual machine
	       user	= "root" 
	       #modify the password of your virtual machine
	       password	= "password123" 
               }		
	    destination = "demo.zip"
	    source	= "demo.zip"
     }  
}	

resource "vsphere_virtual_machine" "kubernetes_master" {
    name             = "K8s-Master-11"
    folder           = "Kubernetes"
    resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    firmware         = "${data.vsphere_virtual_machine.template.firmware}"
    num_cpus 	     = 8
    memory   	     = 16384
    guest_id 	     = "${data.vsphere_virtual_machine.template.guest_id}"
    network_interface {
	network_id  	= "${data.vsphere_network.data_network_1.id}"
	adapter_type 	= "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
	}
	network_interface {
	network_id  	= "${data.vsphere_network.data_network_2.id}"
	adapter_type 	= "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
	}
    network_interface {
        network_id  	= "${data.vsphere_network.network.id}"
	adapter_type 	= "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
        }
    disk {
        label            = "disk0"
        size             = "100"
        eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
        thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    }
    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
    clone {
	template_uuid = "${data.vsphere_virtual_machine.template.id}"
	customize {
	  linux_options {
	   host_name = "K8s-Master-191"
	   domain    = "test.lab"
        }
       	network_interface {
	   ipv4_address = "10.10.20.191"
	   ipv4_netmask = 24
	}
        network_interface {
	   ipv4_address = "10.10.30.191"
	   ipv4_netmask = 24
	}      
        network_interface {
	   ipv4_address = "10.10.10.191"
	   ipv4_netmask = 24
	}
	ipv4_gateway 	= "10.10.10.1"
	dns_server_list = ["8.8.8.8", "8.8.4.4"]
        }   
    }
}

resource "vsphere_virtual_machine" "kubernetes_worker" {
    count	     = "3"
    name             = "K8s-Worker-19${count.index + 2}"
    folder           = "Kubernetes"
    resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    firmware         = "${data.vsphere_virtual_machine.template.firmware}"
    num_cpus 		 = 8
    memory   		 = 16384
    guest_id 		 = "${data.vsphere_virtual_machine.template.guest_id}"
    network_interface {
        network_id  	= "${data.vsphere_network.data_network_1.id}"
	adapter_type 	= "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
	}
    network_interface {
	network_id  	= "${data.vsphere_network.data_network_2.id}"
	adapter_type 	= "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
	}
    network_interface {
        network_id   	= "${data.vsphere_network.network.id}"
        adapter_type 	= "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
        }
    disk {
    label            = "disk0"
    size             = "100"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    }
    scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
    clone {
	template_uuid = "${data.vsphere_virtual_machine.template.id}"
	customize {
	  linux_options {
	   host_name = "K8s-Worker-19${count.index + 2}"
	   domain    = "test.lab"
        }
       	network_interface {
	   ipv4_address = "10.10.20.19${count.index + 2}"
	   ipv4_netmask = 24
	}
        network_interface {
	   ipv4_address = "10.10.30.19${count.index + 2}"
	   ipv4_netmask = 24
	}
        network_interface {
	   ipv4_address = "10.10.10.19${count.index + 2}"
	   ipv4_netmask = 24
	}		
	   ipv4_gateway    = "10.10.10.1"
	   dns_server_list = ["8.8.8.8", "8.8.4.4"]
	}   
    }
}

output "Rancher_IP" {
  value = "${vsphere_virtual_machine.rancher.default_ip_address}"
}
output "K8s_Master_IPs" {
  value = "${vsphere_virtual_machine.kubernetes_master.default_ip_address}"
}
output "K8s_Worker_IPs" {
  value = "${vsphere_virtual_machine.kubernetes_worker.*.default_ip_address}"
}
