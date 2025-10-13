<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)

# Easy IMM
### Quickstart guide
A guide to deploy easyimm, and configure Intersight Orgs


## Table of Contents

* [Deployment Steps](#deployment-steps)
* [Organization name](#organization-name)
* [Examples](#examples-for-using-the-easy-imm-terraform-modules)
* [Important Notes](#important-notes)
* [YAML Schema Notes](#yaml-schema-notes-for-auto-completion-help-and-error-validation)
* [Recommended Firmware](#recommended-firmware)
* [Environment Variables](#environment-variables)
* [Sensitive Variables for the Policies Module](#sensitive-variables-for-the-policies-module)
* [Execute Terraform Apply/Plan](#execute-the-terraform-applyplan)
* [Terraform Requirements](#requirements)
* [Terraform Providers](#providers)
* [Terraform Modules](#modules)
* [Terraform Inputs](#inputs)
* [Terraform Outputs](#outputs)
* [Sub Modules - Terraform Registry](#sub-modules---terraform-registry)

# Overview

This codebase contains examples on how to configure an Intersight CVA or PVA.

There are examples within this codebase that can be modified or deleted as needed.

The default parameters are as follows;
* Organization is named ABC
* UCS Domain 1 - This UCS X-Series Domain representing the equipment housed in DC1
* UCS Domain 2 - This UCS X-Series Domain representing the equipment housed in DC2


#### Pools
* MAC and IP Pools are created per DC
* IP Pools are created per DC
* MAC Pools are created per DC
* UUID Pools are Global


#### Policies
* This codebase will create the Server Policies including BIOS, Boot, Firmware, Storage, LAN Connectivity etc
* Server, Domain and Chassis policies are created, ie NTP, Syslog, LDAP, Ports

#### Profiles
* Domain, Chassis and Server Profiles are created from Templates, which consumes the above NTP, Syslog, LDAP and Ports policies

#### Templates
* Templates are created for Domain, Chassis and Server Profile


### [<ins>Back to Top<ins>](#easy-imm)


## Deployment steps

1. Deploy and configure Intersight CVA networking and licensing
2. Log in to CVA, create API Key with admin role
3. Set up TFE with API Key and Secret, and all relevant variables
4. Modify global_settings.ezi.yaml - update the intersight_fqdn setting
5. Configure the Intersight Organization names
6. Configure site-specific details, such as
Pools: pools/pools.ezi.yaml
VLANs: 
  Set the VLANs in policies/vlan.ezi.yaml
  Set the VLANs in policies/ethernet.ezi.yaml
7. NTP, DNS, SNMP, IMC, LDAP are all set in policies/management.ezi.yaml
8. Port Policies and Port-Channels are all defined in policies/ports.ezi.yaml
9. Chassis: Chassis Profiles are set in profiles/chassis.ezi.yaml
10. Domain: Domain Profiles are set in profiles/domain.ezi.yaml



### [<ins>Back to Top<ins>](#easy-imm)


## Organization name
This codebase can use a single Organisation (Org) name, or multiple Orgs.
To change the Org names, it will need to be updated in the file `organizations/organizations.ezi.yaml`.

#### Creating the Org in `organizations/organizations.ezi.yaml`
```yaml
ABC:                        <-- Org name defined here
  create_organization: true
  description: ABC org
```

#### Updating the `*.ezi.yaml` files in sub directories example
When deploying a Policy, Profile, Pool or Template into an Organization, the configuration must begin with the Organization name, ie ABC
```yaml
ABC:                        <-- This must be changed in all files
  policies:
    scrub:
      - bios: true
        disk: true
        name: Pol_scrub_default
```


### [<ins>Back to Top<ins>](#easy-imm)



## Examples for Using the Easy IMM Terraform Modules

Examples are shown in the following directories:
|Directory|Module|Note |
|--|--|--|
|organizations|Organization(s)|Can define individual or multiple Orgs
| policies | Policies | Defines Domain, Chassis and Server policies |
| pools | Pools | Defines MAC, UUID, IP, WWPN, WWNN Pools. |
| profiles | Profiles | Defines Domain, Chassis and Server profiles.  |
| templates | Templates | Defines Domain, Chassis and Server templates. |



### [<ins>Back to Top<ins>](#easy-imm)

### IMPORTANT NOTES

Take notice of the `ezi.yaml` extension on the files.  This is how the  `data.utils_yaml_merge.model`, in the `main.tf`, is configured to recognize the files that should be imported with the module.

The Structure of the YAML files is very flexible.  You can have all the YAML Data in a single file or you can have it in multiple individual folders like is shown in this module.  The important part is that the `data.utils_yaml_merge.model` is configured to read the folders that you put the Data into.

When defining Identity reservations under a server profile, see example in `profiles` folder, note the flag in the example with `ignore_reservations`.  Reservation records are ephimeral.  Meaning that as soon as the reservation is assigned to a server profile, the identity reservation record is removed from the API.  Thus, after you run the first plan and the identities are created, this flag should be configured to `true` or you need to remove the reservations from the `server_profiles`.  Either way the reservations will only work on the first apply.  Subsequent applies with the reservations defined will cause the plan/apply to fail due to the identity being consumed.


### [<ins>Back to Top<ins>](#easy-imm)

## YAML Schema Notes for auto-completion, Help, and Error Validation:

If you would like to utilize Autocomplete, Help Context, and Error Validation, `(HIGHLY RECOMMENDED)` make sure the files all utilize the `.ezi.yaml` file extension.

First install the `Redhat: YAML` exension to Visual Studio Code or VSCodium: https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml

Then, in Visual Studio Code: Settings > Settings > Search for `YAML: Schema`: Click edit in `settings.json`.  In the `yaml.schemas` section, paste:

```bash
"https://raw.githubusercontent.com/terraform-cisco-modules/easy-imm/main/yaml_schema/easy-imm.json": "*.ezi.yaml"
```


### [<ins>Back to Top<ins>](#easy-imm)

## Environment Variables

Note that all the variables in `variables.tf` are marked as sensitive.  Meaning these are variables that shouldn't be exposed due to the sensitive nature of them.

Take note of the `locals.tf` that currently has the following sensitive variables defined:

  * `certificate_management`
  * `drive_security`
  * `firmware`
  * `ipmi_over_lan`
  * `iscsi_boot`
  * `ldap`
  * `local_user`
  * `persistent_memory`
  * `snmp`
  * `virtual_media`

The Reason to add these variables as maps of string is to allow the flexibility to add or remove iterations of these sensitive variables as needed.  Sensitive Variables cannot be iterated with a `for_each` loop.  Thus instead of adding these variables to the YAML schema, directly, they are added to these seperate maps to allow lookup of the variable index.

In example, if you needed to add 100 iterations of the `certificate_management` variables you can do that, and simply reference the index in the map of the iteration that will consume that instance.


### [<ins>Back to Top<ins>](#easy-imm)

## Sensitive Variables and API keys

Take note of the `locals.tf` that currently has all the sensitive variables mapped.
This is the default sensitive variable mappings.

The first environment variables that must be defined are the Intersight API key and secret keys, as below.  These are created in Intersight and will inherit the current user's privileges.  
To create a key open Intersight and browse to `Settings > Keys` then generate an API v3 Key. This will provide the API Key ID and the Secret Key file.

The API Key ID looks similar to this `68be5dca75sadf1ee546ab/68be669d75sdf61301ea23d74/68bf6sadf756461301ea24198`
The API Secret Key looks similar to this
```
-----BEGIN EC PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGC5sad7ffAwEHBG0wawIBAQQgtHmOy6mwOAhR2zvh
MKYnEyosdf788asetP02x8BCKoGhRANCAARAtcW97o3sadf7a+B2grdjkuBTNZdsLbu
7pQ7+SddHe912QEQLHrZKE6HAeRlGvlqQNssdaff44ftf9hH/ah3RMQrY
-----END EC PRIVATE KEY-----
```


To set the Intersight API Key and Secret, use the environment variables as below
#### Linux
```bash
export TF_VAR_intersight_api_key_id="<your-api-key>"
export TF_VAR_intersight_secret_key="<secret-key-file-contents>"
```



### Terraform Cloud/Enterprise - Workspace Variables

- Add variable `intersight_api_key_id` with the value of <ins>your-intersight-api-key</ins>
- Add variable `intersight_secret_key` with the value of <ins>your-intersight-secret-file-contents</ins>
- Add additional variables as required for the sensitive policy values

#### Add Other Variables as discussed below based on use cases.





### Certificate Management

  * `cert_mgmt_certificate`: Options are by default 1-5 for Up to 5 Certificates.  Variable Should Point to the File Location of the PEM Certificate or be the value of the PEM certificate.
  * `cert_mgmt_private_key`: Options are by default 1-5 for Up to 5 Private Keys.  Variable Should Point to the File Location of the PEM Private Key or be the value of the PEM Private Key.

#### Linux

```bash
export TF_VAR_cert_mgmt_certificate_1='<cert_mgmt_certificate_file_location>'
```
```bash
export TF_VAR_cert_mgmt_private_key_1='<cert_mgmt_private_key_file_location>'
```


### Drive Security - KMIP Sensitive Variables
  * `drive_security_current_security_key_passphrase`: Used by Manual and Remote Key Management, if the server has a previous passphrase configured.
  * `drive_security_new_security_key_passphrase`: Used by Manual Key Management to Assign a new passphrase to the server.
  * `drive_security_authentication_password`: If Authentication is supported/used by the KMIP Server, This is the User Password to Configure.
  * `drive_security_server_ca_certificate`: KMIP Server CA Certificate Contents.

#### Linux
```bash
export TF_VAR_drive_security_authentication_password='<drive_security_authentication_password>'
export TF_VAR_drive_security_server_ca_certificate='<drive_security_server_ca_certificate_file_location>'
```

### Firmware - CCO  Credentials
These variables are used in Intersight to retrieve UCS Firmware recommendations and download the Firmware bundles.
  * `cco_user`: If Configuring Firmware Policies, the CCO User for Firmware Downloads.
  * `cco_password`: If Configuring Firmware Policies, the CCO Password for Firmware Downloads.

#### Linux - without tfenv
```bash
export TF_VAR_cco_user='<cco_user>'
export TF_VAR_cco_password='<cco_password>'
```

#### TFE
```bash
cco_user='<cco_user>'
cco_password='<cco_password>'
```

### [<ins>Back to Top<ins>](#easy-imm)

## Execute the Terraform Apply/Plan

### Terraform Cloud

When running in Terraform Cloud with VCS Integration the first Plan will need to be run from the UI but subsiqent runs should trigger automatically


### Terraform CLI

* Execute the Plan - Linux

```bash
# First time execution requires initialization.  Not needed on subsequent runs.
terraform init
terraform plan -out="main.plan"
terraform apply "main.plan"
```


### [<ins>Back to Top<ins>](#easy-imm)



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | 1.0.61 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.9.1 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.1.3 |

### [<ins>Back to Top<ins>](#easy-imm)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_utils"></a> [utils](#provider\_utils) | 0.2.6 |

### [<ins>Back to Top<ins>](#easy-imm)

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_organizations"></a> [organizations](#module\_organizations) | terraform-cisco-modules/organizations/intersight | 4.2.11-20250410042505151 |
| <a name="module_pools"></a> [pools](#module\_pools) | terraform-cisco-modules/pools/intersight | 4.2.11-20250410042505151 |
| <a name="module_policies"></a> [policies](#module\_policies) | terraform-cisco-modules/policies/intersight | 4.2.11-20250410042505151 |
| <a name="module_profiles"></a> [profiles](#module\_profiles) | terraform-cisco-modules/profiles/intersight | 4.2.11-20250410042505151 |

**NOTE: When the Data is merged from the YAML files, it will run through the modules using for_each loop(s).  Sensitive Variables cannot be added to a for_each loop, instead use the variables below to add sensitive values for policies.**

### [<ins>Back to Top<ins>](#easy-imm)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_intersight_api_key_id"></a> [intersight\_api\_key\_id](#input\_intersight\_api\_key\_id) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_intersight_secret_key"></a> [intersight\_secret\_key](#input\_intersight\_secret\_key) | Intersight Secret Key. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_certificate_1"></a> [cert\_mgmt\_certificate\_1](#input\_cert\_mgmt\_certificate\_1) | The Server Certificate, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_certificate_2"></a> [cert\_mgmt\_certificate\_2](#input\_cert\_mgmt\_certificate\_2) | The Server Certificate, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_certificate_3"></a> [cert\_mgmt\_certificate\_3](#input\_cert\_mgmt\_certificate\_3) | The Server Certificate, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_certificate_4"></a> [cert\_mgmt\_certificate\_4](#input\_cert\_mgmt\_certificate\_4) | The Server Certificate, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_certificate_5"></a> [cert\_mgmt\_certificate\_5](#input\_cert\_mgmt\_certificate\_5) | The Server Certificate, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_private_key_1"></a> [cert\_mgmt\_private\_key\_1](#input\_cert\_mgmt\_private\_key\_1) | The Server Private Key, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_private_key_2"></a> [cert\_mgmt\_private\_key\_2](#input\_cert\_mgmt\_private\_key\_2) | The Server Private Key, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_private_key_3"></a> [cert\_mgmt\_private\_key\_3](#input\_cert\_mgmt\_private\_key\_3) | The Server Private Key, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_private_key_4"></a> [cert\_mgmt\_private\_key\_4](#input\_cert\_mgmt\_private\_key\_4) | The Server Private Key, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cert_mgmt_private_key_5"></a> [cert\_mgmt\_private\_key\_5](#input\_cert\_mgmt\_private\_key\_5) | The Server Private Key, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_drive_security_current_security_key_passphrase"></a> [drive\_security\_current\_security\_key\_passphrase](#input\_drive\_security\_current\_security\_key\_passphrase) | Drive Security Current Security Key Passphrase for Manual or Remote Key Management.  It must meet the following criteria:<br>  - One Uppercase Letter<br>  - One LowerCase Letter<br>  - One Number<br>  - One Special Character: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_drive_security_new_security_key_passphrase"></a> [drive\_security\_new\_security\_key\_passphrase](#input\_drive\_security\_new\_security\_key\_passphrase) | Drive Security New Security Key Passphrase for Manual Key Management.  It must meet the following criteria:<br>  - One Uppercase Letter<br>  - One LowerCase Letter<br>  - One Number<br>  - One Special Character: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_drive_security_authentication_password"></a> [drive\_security\_authentication\_password](#input\_drive\_security\_authentication\_password) | Drive Security User Password. | `string` | `""` | no |
| <a name="input_drive_security_server_ca_certificate"></a> [drive\_security\_server\_ca\_certificate](#input\_drive\_security\_server\_ca\_certificate) | Drive Security Server CA Certificate, in PEM Format, File Location. | `string` | `"blah.txt"` | no |
| <a name="input_cco_password"></a> [cco\_password](#input\_cco\_password) | Cisco.com Authentication Password.  It must meet the following criteria:<br>  - One Uppercase Letter<br>  - One Lowercase Letter<br>  - One Number<br>  - One Special Character: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 12 and 60 Characters in Length. | `string` | `""` | no |
| <a name="input_cco_user"></a> [cco\_user](#input\_cco\_user) | CCO User Account Email for Firmware Policies. | `string` | `"cco_user"` | no |
| <a name="input_ipmi_encryption_key"></a> [ipmi\_encryption\_key](#input\_ipmi\_encryption\_key) | Encryption key to use for IPMI communication. It should have an even number of hexadecimal characters and not exceed 40 characters. | `string` | `""` | no |
| <a name="input_iscsi_boot_password"></a> [iscsi\_boot\_password](#input\_iscsi\_boot\_password) | Password to Assign to the iSCSI Boot Policy if doing Authentication. It can be any string that adheres to the following constraints.<br>  - Any non-white space character<br>  - Be between 12 and 16 Characters in Length. | `string` | `""` | no |
| <a name="input_binding_parameters_password"></a> [binding\_parameters\_password](#input\_binding\_parameters\_password) | The password of the user for initial bind process with an LDAP Policy. It can be any string that adheres to the following constraints.<br>  - Any non-white space character<br>  - Be between 8 and 254 Characters in Length. | `string` | `""` | no |
| <a name="input_local_user_password_1"></a> [local\_user\_password\_1](#input\_local\_user\_password\_1) | Password to assign to a Local User Policy -> User.<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 127 Characters in Length. | `string` | `""` | no |
| <a name="input_local_user_password_2"></a> [local\_user\_password\_2](#input\_local\_user\_password\_2) | Password to assign to a Local User Policy -> User.<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 127 Characters in Length. | `string` | `""` | no |
| <a name="input_local_user_password_3"></a> [local\_user\_password\_3](#input\_local\_user\_password\_3) | Password to assign to a Local User Policy -> User.<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 127 Characters in Length. | `string` | `""` | no |
| <a name="input_local_user_password_4"></a> [local\_user\_password\_4](#input\_local\_user\_password\_4) | Password to assign to a Local User Policy -> User.<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 127 Characters in Length. | `string` | `""` | no |
| <a name="input_local_user_password_5"></a> [local\_user\_password\_5](#input\_local\_user\_password\_5) | Password to assign to a Local User Policy -> User.<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 127 Characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_fallback_key_chain_secret_1"></a> [mac\_sec\_fallback\_key\_chain\_secret\_1](#input\_mac\_sec\_fallback\_key\_chain\_secret\_1) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_fallback_key_chain_secret_2"></a> [mac\_sec\_fallback\_key\_chain\_secret\_2](#input\_mac\_sec\_fallback\_key\_chain\_secret\_2) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_fallback_key_chain_secret_3"></a> [mac\_sec\_fallback\_key\_chain\_secret\_3](#input\_mac\_sec\_fallback\_key\_chain\_secret\_3) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_fallback_key_chain_secret_4"></a> [mac\_sec\_fallback\_key\_chain\_secret\_4](#input\_mac\_sec\_fallback\_key\_chain\_secret\_4) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_fallback_key_chain_secret_5"></a> [mac\_sec\_fallback\_key\_chain\_secret\_5](#input\_mac\_sec\_fallback\_key\_chain\_secret\_5) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_primary_key_chain_secret_1"></a> [mac\_sec\_primary\_key\_chain\_secret\_1](#input\_mac\_sec\_primary\_key\_chain\_secret\_1) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_primary_key_chain_secret_2"></a> [mac\_sec\_primary\_key\_chain\_secret\_2](#input\_mac\_sec\_primary\_key\_chain\_secret\_2) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_primary_key_chain_secret_3"></a> [mac\_sec\_primary\_key\_chain\_secret\_3](#input\_mac\_sec\_primary\_key\_chain\_secret\_3) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_primary_key_chain_secret_4"></a> [mac\_sec\_primary\_key\_chain\_secret\_4](#input\_mac\_sec\_primary\_key\_chain\_secret\_4) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_mac_sec_primary_key_chain_secret_5"></a> [mac\_sec\_primary\_key\_chain\_secret\_5](#input\_mac\_sec\_primary\_key\_chain\_secret\_5) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Must start with the character 'J'<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 144 characters in Length. | `string` | `""` | no |
| <a name="input_persistent_passphrase"></a> [persistent\_passphrase](#input\_persistent\_passphrase) | Secure passphrase to be applied on the Persistent Memory Modules on the server. The allowed characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_access_community_string_1"></a> [access\_community\_string\_1](#input\_access\_community\_string\_1) | The default SNMPv1, SNMPv2c community name or SNMPv3 username to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_access_community_string_2"></a> [access\_community\_string\_2](#input\_access\_community\_string\_2) | The default SNMPv1, SNMPv2c community name or SNMPv3 username to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_access_community_string_3"></a> [access\_community\_string\_3](#input\_access\_community\_string\_3) | The default SNMPv1, SNMPv2c community name or SNMPv3 username to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_access_community_string_4"></a> [access\_community\_string\_4](#input\_access\_community\_string\_4) | The default SNMPv1, SNMPv2c community name or SNMPv3 username to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_access_community_string_5"></a> [access\_community\_string\_5](#input\_access\_community\_string\_5) | The default SNMPv1, SNMPv2c community name or SNMPv3 username to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_auth_password_1"></a> [snmp\_auth\_password\_1](#input\_snmp\_auth\_password\_1) | The SNMPv3 User Authorization password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_auth_password_2"></a> [snmp\_auth\_password\_2](#input\_snmp\_auth\_password\_2) | The SNMPv3 User Authorization password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_auth_password_3"></a> [snmp\_auth\_password\_3](#input\_snmp\_auth\_password\_3) | The SNMPv3 User Authorization password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_auth_password_4"></a> [snmp\_auth\_password\_4](#input\_snmp\_auth\_password\_4) | The SNMPv3 User Authorization password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_auth_password_5"></a> [snmp\_auth\_password\_5](#input\_snmp\_auth\_password\_5) | The SNMPv3 User Authorization password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_privacy_password_1"></a> [snmp\_privacy\_password\_1](#input\_snmp\_privacy\_password\_1) | The SNMPv3 User Privacy password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_privacy_password_2"></a> [snmp\_privacy\_password\_2](#input\_snmp\_privacy\_password\_2) | The SNMPv3 User Privacy password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_privacy_password_3"></a> [snmp\_privacy\_password\_3](#input\_snmp\_privacy\_password\_3) | The SNMPv3 User Privacy password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_privacy_password_4"></a> [snmp\_privacy\_password\_4](#input\_snmp\_privacy\_password\_4) | The SNMPv3 User Privacy password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_privacy_password_5"></a> [snmp\_privacy\_password\_5](#input\_snmp\_privacy\_password\_5) | The SNMPv3 User Privacy password.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `@`, `_`, `*`, `-`<br>  - Be between 8 and 64 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_trap_community_1"></a> [snmp\_trap\_community\_1](#input\_snmp\_trap\_community\_1) | The SNMPv1, SNMPv2c community name to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_trap_community_2"></a> [snmp\_trap\_community\_2](#input\_snmp\_trap\_community\_2) | The SNMPv1, SNMPv2c community name to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_trap_community_3"></a> [snmp\_trap\_community\_3](#input\_snmp\_trap\_community\_3) | The SNMPv1, SNMPv2c community name to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_trap_community_4"></a> [snmp\_trap\_community\_4](#input\_snmp\_trap\_community\_4) | The SNMPv1, SNMPv2c community name to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_snmp_trap_community_5"></a> [snmp\_trap\_community\_5](#input\_snmp\_trap\_community\_5) | The SNMPv1, SNMPv2c community name to include on any trap messages sent to the SNMP host. The name can be 32 characters long.  Allowed Characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `.`, `=`, `!`, `&`, `#`, `$`, `%`, `+`, `^`, `_`, `*`, `-`<br>  - Be between 8 and 32 Characters in Length. | `string` | `""` | no |
| <a name="input_switch_control_aes_primary_key_1"></a> [switch\_control\_aes\_primary\_key\_1](#input\_switch\_control\_aes\_primary\_key\_1) | The key octet string is a shared secret used in cryptographic operations.<br>The valid size and format of the octet string depend on the selected KeyCryptographicAlgorithm and KeyEncryptionType.<br>The allowed characters are:<br>  - Lower or Upper Case Letters<br>  - Numbers<br>  - Special Characters: `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `+`, `_`, `=`, `-`<br>  - Be 16 to 64 characters in length. | `string` | `""` | no |
| <a name="input_vmedia_password_1"></a> [vmedia\_password\_1](#input\_vmedia\_password\_1) | Virtual Media Policy -> Mapping Target Password when authentication is enabled.  Allowed Characters are:<br>  - Any non-white space character<br>  - Be between 6 and 255 Characters in Length. | `string` | `""` | no |
| <a name="input_vmedia_password_2"></a> [vmedia\_password\_2](#input\_vmedia\_password\_2) | Virtual Media Policy -> Mapping Target Password when authentication is enabled.  Allowed Characters are:<br>  - Any non-white space character<br>  - Be between 6 and 255 Characters in Length. | `string` | `""` | no |
| <a name="input_vmedia_password_3"></a> [vmedia\_password\_3](#input\_vmedia\_password\_3) | Virtual Media Policy -> Mapping Target Password when authentication is enabled.  Allowed Characters are:<br>  - Any non-white space character<br>  - Be between 6 and 255 Characters in Length. | `string` | `""` | no |
| <a name="input_vmedia_password_4"></a> [vmedia\_password\_4](#input\_vmedia\_password\_4) | Virtual Media Policy -> Mapping Target Password when authentication is enabled.  Allowed Characters are:<br>  - Any non-white space character<br>  - Be between 6 and 255 Characters in Length. | `string` | `""` | no |
| <a name="input_vmedia_password_5"></a> [vmedia\_password\_5](#input\_vmedia\_password\_5) | Virtual Media Policy -> Mapping Target Password when authentication is enabled.  Allowed Characters are:<br>  - Any non-white space character<br>  - Be between 6 and 255 Characters in Length. | `string` | `""` | no |

### [<ins>Back to Top<ins>](#easy-imm)


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_organizations"></a> [organizations](#output\_organizations) | Outputs from the organizations module. |
| <a name="output_policies"></a> [policies](#output\_policies) | Outputs from the policies module. |
| <a name="output_pools"></a> [pools](#output\_pools) | Outputs from the pools module. |
| <a name="output_profiles"></a> [profiles](#output\_profiles) | Outputs from the profiles module. |

### [<ins>Back to Top<ins>](#easy-imm)


## Sub Modules - Terraform Registry

If you want to see documentation on Variables for Submodules use the links below:

#### * [<ins>Organizations<ins>](https://registry.terraform.io/modules/terraform-cisco-modules/organizations/intersight/latest)

#### * [<ins>Policies<ins>](https://registry.terraform.io/modules/terraform-cisco-modules/policies/intersight/latest)

#### * [<ins>Pools<ins>](https://registry.terraform.io/modules/terraform-cisco-modules/pools/intersight/latest)

#### * [<ins>Profiles<ins>](https://registry.terraform.io/modules/terraform-cisco-modules/profiles/intersight/latest)

#### * [<ins>Intersight IMM<ins>](https://registry.terraform.io/modules/terraform-cisco-modules/imm/intersight/latest)




### [<ins>Back to Top<ins>](#easy-imm)
<!-- END_TF_DOCS -->
