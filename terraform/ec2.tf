provider "aws" {
  shared_credentials_file = "${var.cred_file}"
  profile                 = "default"
  region                  = "${var.aws_region}"
}

data "aws_vpc"  "selected" {
  tags                    = {
    Name                  = "${var.aws_vpc}"
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent             = true

  filter {
    name                  = "name"
    values                = ["golden.image-*"]
  }

  filter {
    name                  = "virtualization-type"
    values                = ["hvm"]
  }
  owners                  = ["0"]
}

 data "aws_subnet_ids" "selected_subnet" {
   vpc_id                  = "${data.aws_vpc.selected.id}"
   tags {
     Tier                  = "${var.subnet_scope}"
   }
 }

 data "aws_security_group" "security_group"{
   id                      = "${var.securitygroup}"
 }

### Launch Instances
resource "aws_instance" "app" {
  subnet_id               = "${element(data.aws_subnet_ids.selected_subnet.ids, count.index)}"
  count                   = "${var.count}"
  key_name                = "aws"
  ami                     = "${data.aws_ami.ubuntu_ami.id}"
  instance_type           = "${var.instanceType}"
  associate_public_ip_address = "${var.publicip}"
  security_groups         = ["${data.aws_security_group.security_group.id}"]
  
  root_block_device {
    volume_size = 8
  }
  tags                    = {
    Name                  = "${var.instanceName}"
    Service               = "${var.serviceName}"
    ServiceVersion        = "${var.serviceVersion}"
    EnvName               = "${var.envName}"
  }
}
