packer {
    required_plugins {
        amazon = {
            version = ">= 0.0.1"
            source = "github.com/hashicorp/amazon"
        }
    }
}
############ DEFINE VARIABLES ##################
# These variables can be manipulated to fit any ami provisioning requirement.
variable "profile" {
    type    = string
    default = "adp_aws"
}

variable "region" {
    type    = string
    default = "us-east-1"
}

variable "instance_type" {
    type    = string
    default = "t2.micro"
}

variable "ssh_username" {
    type    = string
    default = "ec2-user"
}

variable "ami_vault_name" {
    type    = string
    default = "adp_vault_image"
}

variable "ami_consul_name" {
    type    = string
    default = "adp_consul_image"
}

variable "virtualization_type" {
    type    = string
    default = "hvm"
}

variable "image_name" {
    type    = string
    default = "ADP_RHEL-Base_8_x86_2021-04-20_295"
}

variable "root-device-type" {
    type    = string
    default = "ebs"
}

variable "owner-id" {
    type    = string
    default = "711283292668"
}

variable "most_recent_bool" {
    type    = bool 
    default = true
}

variable "tag_key" {
    type    = string
    default = "cluster_name"
}

variable "vault_tag" {
    type    = string
    default = "vault"
}

variable "consul_tag" {
    type    = string
    default = "consul"
}

################## IMAGE DEFINITION ####################
### NOTE: Multi environment build can be achieved in two methods. 
### Method 1 is simply by having credentials into each aws environment in the ~/.aws/credentials file. 
### From here, you will need to change line 15 & 16 to pair with the profile in the creds file. (Not my favorite method)
### Method 2 can be acheived by using the ami_users directive within this script. This will give permission to additional AWS to use this AMI. 

source "amazon-ebs" "adp_rhel_image" {
    profile       = var.profile
    region        = var.region
    instance_type = var.instance_type
    ssh_username  = var.ssh_username
    source_ami_filter {
        filters = {
            virtualization-type = var.virtualization_type
            name = var.image_name
            root-device-type = var.root-device-type
        }
        owners = ["711283292668"]
        most_recent = true
    }
    tags = {
        Builder = "Packer"
    }
}

build {
    source "amazon-ebs.adp_rhel_image" {
        ami_name = "adp_vault_image"
    }

    provisioner "ansible" {
        playbook_file   = "./ansible/build/install.yml"
        extra_arguments = ["--tags", "vault"]
    }
}

build {
    source "amazon-ebs.adp_rhel_image" {
        ami_name = "adp_consul_image"
    }

    provisioner "ansible" {
        playbook_file = "./ansible/build/install.yml"
        extra_arguments = ["--tags", "consul"]
    }
}