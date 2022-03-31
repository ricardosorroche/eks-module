# Module for EKS

Module that creates necessary resources for AWS EKS Cluster.
Resources:

- IAM Policies
- IAM Roles
- Security Groups

  
> **⚠ IMPORTANT**: 
> 
> - This module utilize a private EKS cluster, and requires a VPC, NatGW and subnets configured. You need to inform this. Below there are an example.

## Variables

| Name | Description | Required | Default |
| --- | --- | --- | --- |
|aws_region| The region where the resources will be deployed. | True | |
|cluster_name| The cluster name to use in EKS. | True | |
|vpc_id| The id of VPC. | True | |
|subnet_ids| The id's of the subnets. | True | |
|cluster_version| The version of EKS Cluster, more details [here](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html).| True | |
|cluster_enabled_log_types| The log types collected in the cluster. | True | |
|aws_role_eks| The role used in EKS Cluster. | True | |
|additional_security_group_ids| The secondary security group used in cluster. This is a good practice to attach in other security groups. | True | |
|tags| The tags that will be attached to all created resources, expects an object, example: `{ "app": "my-app" }`| False | |


### Resource

Below an example for utilizing the module:


Example:

```
module "eks_cluster" {
    source          = "../module_eks"
    cluster_version = 1.21
    subnet_ids      = ["subnet-xxxxxx", "subnet-yyyyyy", "subnet-zzzzzz"]
    cluster_name    = "name_used"
    vpc_id          = "vpc-id"
}

```