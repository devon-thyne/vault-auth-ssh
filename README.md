vault-auth-ssh
==============

This role is to configure client machines with the tools they need to interface with HashiCorp Vault and make use of its ssh secrets engine to connect to remote host machines via ssh. This is performed through the installation of vault cli as well as `sshv` which is an custom automated bash command to perform ssh key generation, vault authentication, ssh key signing, and ssh connection to a specified remote machine automatically.

Requirements
------------

* Ansible 2.7+
* Configured Vault policies that allow the user to access Vault ssh secrets engine using at least one of the following auth methods:
    * token
    * ldap
* Supported Operating Systems:
    * RHEL 6.10 & 7.6
    * Ubuntu 14 & 16
    * Mac OS
* If configuring `Mac OS` machine, important to note this role's dependency on `brew` for vault cli installation.

Role Variables
--------------

| variable name              | default value   | description                                                                 | value options                                                                                                                                                                               |
| -------------------------- | --------------- | ----------------------------------------------------------------------------| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| vault_cli_configure        | true            | flag to turn vault cli configuration on/off                                 | `true` - vault cli will installed/configured <br/><br/> `false` - vault cli install/configuration/removal will be skipped                                                                   |
| vault_cli_config_behavior  | configure       | behavior of the vault-cli-configure task                                    | `configure` - apply vault cli configuration <br/><br/> `remove` vault cli will be removed from machine                                                                                      |
| vault_cli_version          | 1.1.3           | vault version to install if within Linux. MacOS will install latest via RPM |                                                                                                                                                                                             |
| vault_cli_install_location | /usr/local/bin  | vault CLI install location if within Linux                                  |                                                                                                                                                                                             |
| sshv_configure             | true            | flag to turn sshv configuration on/off                                      | `true` - sshv will be installed/configured <br/><br/> `false` - sshv install/configuration/removal will be skipped                                                                          |
| sshv_config_behavior       | configure       | behavior of the sshv-configure task                                         | `configure` - apply sshv configuration <br/><br/> `remove` sshv will be removed from machine                                                                                                |
| sshv_config_update         | false           | flag tp update current sshv installation in place                           | `false` - will not force update existing sshv installation on host and fail if it is already installed <br/><br/> `true` - allow sshv installation to overwrite any existing installation   |

Dependencies
------------

* In or to connect to a remote machine, `sshv` requires that the remote machine be pre-configured with the `vault-management-host` ansible role. What this role entails is that the remote machine trusts vault as a certificate authority and allows remote client to connect via ssh using vault signed ssh key pairs. After this pre-configuration, `sshv` can successfully make use of vault's ssh secrets engine to sign a newly generated ssh key pair and use it to connect to the pre-configured remote host.

Example Playbook
----------------

The standard location for our playbook to simply include this `vault-auth-ssh` role is located in `playbooks/vault/vault-configure-client.yml`

```
- hosts: localhost
  roles:
    - vault-auth-ssh
```

Example Playbook Execution
--------------------------

Assuming the executed playbook includes the `vault-auth-ssh` as depicted in the **Example Playbook** section above. The below examples show the use of the playbook that comes out of the box installed in the default `/etc/ansible/` directory, but this value can be substituted for the path to any other playbook that includes this role.

1. Running playbook with all default values
```
ansible-playbook -i localhost, -c local /etc/ansible/playbooks/vault/vault-configure-client.yml
```

2. Running the playbook with any number of specified variables. For documentation on the passable variables to this role and their possible values please see the **Role Variables** section above.
```
ansible-playbook -i localhost, -c local /etc/ansible/playbooks/vault/vault-configure-client.yml -e "VARIABLE1=VALUE VARIABLE2=VALUE"
```

Author Information
------------------

* Devon Thyne (devon-thyne)

