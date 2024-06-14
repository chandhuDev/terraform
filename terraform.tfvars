public_subnets_map = {
  "us-east-1a" = "10.0.1.0/24",
  "us-east-1b" = "10.0.2.0/24",
}

private_subnets_map = {
  "us-east-1a" = "10.0.4.0/24",
  "us-east-1b" = "10.0.5.0/24",
}

ami-id = "ami-0fe630eb857a6ec83"

intance_type = "t2.medium"

public_azs = "us-east-1a"

eks-node-name = "nodes"

region = "us-east-1"

ec2-subnet = "us-east-1a"
