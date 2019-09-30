# Latest Version
4.2-000003

# Version History

## Version 4.2-000003 (devon-thyne)
### Enhancement - Add ssh verbosity
* Added optional flag to sshv command to run with verbosity enabled

## Version 4.2-000002 (devon-thyne)
### Enhancement - Added sshv windows support with Git Bash dependency
* Added support to use sshv from a windows machine with Git Bash already installed

### Bug fix - MacOS supported bash syntax
* Updated install/uninstall scripts for sshv to use bash syntax that is supported by older bash versions commonly used by MacOS

## Version 4.2-000001 (devon-thyne)
### Initial sshv program created
* Automatically performs overhead steps for clients to leverage HashiCorp Vault ssh secrets engine to generate and sign a new ssh key pair to remote connect to host machines
* Support for Linux

