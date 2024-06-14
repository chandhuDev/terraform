provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "./vpc"
}

module "subnets" {
  source              = "./subnets"
  public_subnets_map  = var.public_subnets_map
  private_subnets_map = var.private_subnets_map
  vpc-name            = module.vpc.vpc_id
}

module "igw" {
  source            = "./igw"
  vpc-id            = module.vpc.vpc_id
  public_subnet_ids = module.subnets.subnet_ids_pb
}

module "nat" {
  source            = "./nat"
  igw-id            = module.igw.igw-id
  vpc-id            = module.vpc.vpc_id
  public_subnet_ids = module.subnets.subnet_ids_pb
}

module "pr-table" {
  source             = "./pr-route-table"
  vpc-id             = module.vpc.vpc_id
  nat-gateway        = module.nat.nat
  private_subnet_ids = module.subnets.subnet_ids_pr
}

module "pb_table" {
  source            = "./pb-route-table"
  vpc-id            = module.vpc.vpc_id
  igw               = module.igw.igw-id
  public_subnet_ids = module.subnets.subnet_ids_pb
}

module "sg" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source            = "./ec2"
  ami               = var.ami-id
  instance_type     = var.intance_type
  az                = var.public_azs
  vpc-id            = module.vpc.vpc_id
  aws_key_pair_name = "${module.vpc.vpc_id}-key-pair"
  public_subnet_ids = module.subnets.subnet_ids_pb[var.ec2-subnet]
  sg = module.sg.sg-id
}

module "eks" {
  source             = "./eks"
  vpc-id             = module.vpc.vpc_id
  private_subnet_ids = module.subnets.subnet_ids_pr
}

module "eks-nodes" {
  source      = "./eks-nodes"
  nodeName    = "${module.eks.eks-name}-${var.eks-node-name}"
  eks-name    = module.eks.eks-name
  subnet_ids  = module.subnets.subnet_ids_pr
  region      = var.region
  eks-version = module.eks.eks-version
}

