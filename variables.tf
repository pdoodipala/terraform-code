variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "cluster_version" {
  type = string
  default = "1.27"
}

variable "cluster_name" {
  type = string
  default = "eks-cluster"
}

variable "instance_ami" {
  type = string
  default = "ami-0c3472daea3f355b7"
}

variable "instanceType" {
  type = string
  default = "t2.small"
}

variable "root_device_size" {
  type = string
  default = "30"
}
variable "root_device_type" {
  type = string
  default = "gp2"
}

variable "key_pair_name" {
  type = string
  default = "terraform"
}