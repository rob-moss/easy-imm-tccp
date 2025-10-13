#############
# Create RBACs in CVA with IS Groups mapped to LDAP Groups in IDP
# Create Intersight Groups mapped to LDAP Groups in IDP
# Create Roles per Tenant, mapped to Orgs
# * User:     Tenant:readonly + system:readonly 
# * KVM User: Tenant:readonly + Tenant:kvmuser + system:readonly
# Create ?

#######
# Links
# IS IAM: https://github.com/CiscoDevNet/terraform-provider-intersight/tree/main/examples/iam
# https://github.com/CiscoDevNet/terraform-provider-intersight/blob/main/examples/organization/organization_organization.md
# https://github.com/CiscoDevNet/terraform-provider-intersight/blob/main/examples/resource/resource_group.md














# Create Orgs
resource "intersight_organization_organization" "organization1" {
  name = "organization1"
  account {
    object_type = "iam.Account"
    moid        = var.account
  }
  resource_groups {
    moid        = var.resource_group
    object_type = "resource.Group"
    class_id    = "resource.Group"
  }

}

variable "account" {
  type        = string
  description = "Moid of iam.Account"
}

variable "resource_group" {
  type        = string
  description = "Moid of resource.Group"
}

###########################
