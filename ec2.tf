# ec2-security group
resource "aws_security_group" "allow_ssh_eks" {
  name        = "allow_ssh_eks"
  description = "Allow external SSH connectivity to EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_eks"
  }
}


# iam role and policy
resource "aws_iam_role" "eks-ec2-role" {
  name = "eks-role-playleap-dev"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            }
        }
    ]
}
POLICY  
}

resource "aws_iam_role_policy_attachment" "amazon-eks-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks-ec2-role.name
}

resource "aws_iam_instance_profile" "eks-ec2-profile" {
  name = "eks_profile"
  role = aws_iam_role.eks-ec2-role.name
}

# ssh keypair
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "private_key" {
  filename        = "terraform.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.key.public_key_openssh
}

# resource block for eip #
resource "aws_eip" "eksec2eip" {
  vpc      = true
}

# resource block for ec2 and eip association #
resource "aws_eip_association" "eksec2eip_assoc" {
  instance_id   = aws_instance.eks-instance.id
  allocation_id = aws_eip.eksec2eip.id
}

resource "aws_instance" "eks-instance" {
    ami = var.instance_ami
    subnet_id = aws_subnet.public_subnets[0].id
    instance_type = var.instanceType
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.allow_ssh_eks.id]
    key_name = aws_key_pair.key_pair.key_name
    iam_instance_profile = aws_iam_instance_profile.eks-ec2-profile.name

    root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.root_device_size
    volume_type           = var.root_device_type
  }

  user_data = <<-EOL
  #!/bin/bash -xe

  # install kubectl for Kubernetes 1.27 
  curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
  curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl.sha256
  sha256sum -c kubectl.sha256
  openssl sha1 -sha256 kubectl
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
  echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
  kubectl version --short --client

  #install aws cli
  apt update -y 
  apt-get install awscli -y
  AWS_ACCESS_KEY_ID = AKIATVGY6G6PJRUUEPP5
  AWS_SECRET_ACCESS_KEY = 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
  AWS_REGION = eu-central-1
  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile terraform && aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile terraform && aws configure set region "$AWS_REGION" --profile terraform

  # Get the eks config file
  aws eks --region eu-central-1 update-kubeconfig --name eks-cluster

  #install eksctl for adding iam identity
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl /usr/local/bin
  eksctl version
  eksctl create iamidentitymapping  --cluster eks-cluster --region=eu-central-1 --arn arn:aws:iam::251710551966:user/terraform-code  --username terraform-user

  EOL
  
  tags = {
    "Name" = "instance"
  }
}