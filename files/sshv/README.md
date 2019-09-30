Vault SSH Secrets Engine Automated Client Usage Script
======================================================

`sshv` aims to help any client easily make use of HashiCorp Vault's SSH Secrets Engine. Functionally, it performs the overhead steps required to use the secrets engine automatically, allowing each user to use Vault's SSH Secrets Engine with next to no change in their normal workflow. The goal is to as closely as possible emulate the normal user experience using the familiar `ssh` command, but leverage Vault for ssh key pair signing automatically.

Installation
============

Please see the respective section for your machine's platform for installation instructions.

Linux
-----

### Dependencies 

* Vault cli
* Supported Distrobutions:
    * Red Hat Enterprise Linux 7
    * Red Hat Enterprise Linux 6
    * Ubuntu 16
    * Ubuntu 14

### Instructions

By default, `sshv` is installed globally via the installation script into the `/usr/local/bin` folder

To install sshv globally, run the `install-sshv.sh` script with elevated priviledges:
```
sudo bash install-sshv.sh
```

MacOS
-----

### Dependencies 

* Vault cli
* Brew

### Instructions

By default, `sshv` is installed globally via the installation script into the `/usr/local/bin` folder

To install sshv globally, run the `install-sshv.sh` script with elevated priviledges:
```
sudo bash install-sshv.sh
```

Windows
-------

### Dependencies 

* Vault cli
* Git Bash

### Instructions

By default, `sshv` in set to install locally for the executing user to the `/c/Users/<USER>/.ssh/` folder and configure the user's `.bash_profile`.

Please run the following steps:
```
bash install-sshv.sh
source ~/.bash_profile
```

Installation Help
-----------------

For help or additional installation options, please reference the `install-sshv.sh` help page by executing:
```
bash install-sshv.sh --help
```

As a note, if you experience trouble with the installation process using the `install-sshv.sh` script, the alternative manual method is to simply copy the `sshv` executable into any desired location on the user's path and give it executable permissions.

Usage Instructions
==================

This script was designed to be as familiar as possible to the already widely used `ssh` command.

Assumptions
-----------

The follow assumptions 

* The `sshv` command installed on the machine. See installation instructions above for details.
* Vault cli installed on client machine. For installation instructions, please see the official Vault Project documentation [here] (https://www.vaultproject.io/docs/install/).
* The remote host being connected to with `sshv` has been pre-configured to trust Vault as a Certificate Authority. This can be done using the `vault-management-host` ansible role.
* The user is accepts that the command will autonomously store/overwrite the following files in their user's `.ssh/` directory:
 * sshv_key
 * sshv_key.pub
 * sshv_key-cert.pub

Syntax
------

Follow the `sshv` command with `user@host` specifying the user the client intends to connect as to the specified hostname/IP address:
```
sshv user@host
```
or with options specified:
```
sshv user@host [OPTIONS]
```

Options
-------

1. Specify a different authentication method (-m or --login_method flag). The default behavior is to use token auth to read in existing Vault auth token from `~/.vault-token`. If this is not found, the next place to look is in the `VAULT_TOKEN` environment variable. Choices:
    * Token (default)
    * LDAP

    ```
    sshv user@host -m ldap
    ```

2. Specify a specific Vault to use for SSH key signing (-u or --vault_url flag):
    ```
    sshv user@host -u https://url_to_vault:port
    ```
    
3. Specify a specific engine within Vault to use for SSH key signing (-e or --engine flag):
    ```
    sshv user@host -e ENGINE_NAME
    ```

Help
----

The help page along with its documentation of the many optional flags passable to sshv can be accessed using the `--help` option flag:
```
sshv --help
```

Removal
=======

The removal process is the same accross all machine platforms.
```
bash uninstall-sshv.sh
```

Please note, that if special flags are passed to the installation script to install for specific users, to specific locations, or other, the uninstall script should be passed with the same additional options.
```
bash uninstall-sshv.sh <SAME OPTIONS AS CUSTOM INSTALLATION>
```

Uninstall Help
--------------

For help or additional uninstall options, please reference the `uninstall-sshv.sh` help page by executing:
```
bash uninstall-sshv.sh --help
```

As a note, if you experience trouble with the uninstall process using the `uninstall-sshv.sh` script, the alternative manual method is to simply remove the `sshv` executable from wherever it is installed on your machine.

