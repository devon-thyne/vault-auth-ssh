#!/bin/bash

# Synopsis: Installs sshv bash script onto machine so clients can make automatic use of HashiCorp Vault's ssh secrets engine and remotely connect to host machines with Vault signed ssh key pairs with ease
# Dependencies: bash
# Author(s): 
#   Devon Thyne (devon-thyne)
# Modified: 20190725
# Version: 4.2-000002


##### sshv installation script help
# Syntax:
#   . ./install-sshv.sh [OPTIONS]
#
#
# Options:
#
#   -f or --force : (optional) force installation even if sshv already installed in other location or will overwrite if installing to the same location as existing installation
#
#   -h or --help : (optional) display help page for sshv install-sshv.sh script
#
#   -l [PATH] or --location [PATH] : (optional) install sshv executable to specific location. Must be absolute path (default (Linux/MacOS): /usr/local/bin, default Windows: /c/Users/<USER>/.ssh/)
#
#   -o [OPERATING SYSTEM] or --os [OPERATING SYSTEM] : (optional) manually configures script to install sshv for the passed operating system. Default behavior is to scan list of supported Operating Systems and install on detected platform.
#     Options:
#       rhel7 : Red Hat Enterprise Linux 7
#       rhel6 : Red Hat Enterprise Linus 6
#       macos : Mac OS
#       ubuntu16 : Ubuntu 16
#       ubuntu14 : Ubuntu 14
#       windows : Windows
#
#   -u [USER] or --user [USER] : (optional), add install location to environment variable PATH for specific user. Cannot be root. By default, Windows installation will auto-detect this value.
#
#
# Dependencies:
#
#   All Platforms:
#     - vault cli
#   
#   MacOS:
#     - brew
#
#   Windows:
#     - git bash



# Default install location set to /usr/local/bin
SSHV_INSTALL_LOCATION=/usr/local/bin

# Default do not add install location to PATH
SSHV_ADD_TO_PATH=false

# Default force installation set to false
SSHV_FORCE_INSTALL=false



# Traverse option flags input as command line arguments
while [ ! $# -eq 0 ]
do
	case "$1" in
		-f | --force)
			SSHV_FORCE_INSTALL=true	
			;;
		-h | --help)
			echo -e "Help Page - sshv install-sshv.sh\n\nScript to install 'sshv' command\n\n\nSyntax:\n\n\tbash install-sshv.sh [OPTIONS]\n\n\nOptions:\n\n\t-f or --force : (optional) force installation even if sshv already installed in other location or will overwrite if installing to the same location as existing installation\n\n\t-h or --help : (optional) display help page for sshv install-sshv.sh script\n\n\t-l [PATH] or --location [PATH] : (optional) install sshv executable to specific location. Must be absolute path. (default (Linux/MacOS): /usr/local/bin, default Windows: /c/Users/<USER>/.ssh/)\n\n\t-o [OPERATING SYSTEM] or --os [OPERATING SYSTEM] : (optional) manually configures script to install sshv for the passed operating system. Default behavior is to scan list of supported Operating Systems and install on detected platform.\n\t\tOptions:\n\t\t\trhel7 : Red Had Enterprise Linux 7\n\t\t\trhel6 : Red Hat Enterprise Linux 6\n\t\t\tmacos : Mac OS\n\t\t\tubuntu16 : Ubuntu 16\n\t\t\tubuntu14 : Ubuntu 14\n\t\t\twindows : Windows\n\n\t-u [USER] or --user [USER] : (optional) add install location to environment variable PATH for specific user. Cannot be root. By default, Windows installation will auto-detect this value.\n\n\nDependencies:\n\n\tAll Platforms:\n\t\t- vault cli\n\n\tMacOS:\n\t\t- brew\n\n\tWindows:\n\t\t- git bash"
			exit 0
			;;
		-l | --location)
			shift
			SSHV_INSTALL_LOCATION=$1
			;;
		-o | --os)
			shift
			SSHV_OS=$1
			;;
		-u | --user)
			shift
			SSHV_ADD_TO_PATH=true
			SSHV_USER=$1
			if [ ! -d "/home/$SSHV_USER" ]; then
          			echo "Error, passed user does not exist on this machine. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'."
				exit 1
			fi
			;;
		*)
			echo "Error, invalid flag '$1' passed to installation script. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'."
			exit 1
			;;
	esac
	shift
done

# Detect operating system
if [ -z "$SSHV_OS" ]; then
	SSHV_DETECTED_OS=$( cat /etc/redhat-release 2> /dev/null )
        if [[ "$SSHV_DETECTED_OS" == *"Red Hat Enterprise Linux Server release 7"* ]]; then
                SSHV_OS=rhel7
        fi
        SSHV_DETECTED_OS=$( cat /etc/redhat-release 2> /dev/null )
        if [[ "$SSHV_DETECTED_OS" == *"Red Hat Enterprise Linux Server release 6"* ]]; then
                SSHV_OS=rhel6
        fi
        SSHV_DETECTED_OS=$( lsb_release -a 2> /dev/null )
        if [[ "$SSHV_DETECTED_OS" == *"Ubuntu 16"* ]]; then
                SSHV_OS=ubuntu16
        fi
        SSHV_DETECTED_OS=$( lsb_release -a 2> /dev/null )
        if [[ "$SSHV_DETECTED_OS" == *"Ubuntu 14"* ]]; then
                SSHV_OS=ubuntu14
        fi
        SSHV_DETECTED_OS=$( sw_vers 2> /dev/null )
        if [[ "$SSHV_DETECTED_OS" == *"Mac OS"* ]]; then
                SSHV_OS=macos
        fi
        if [[ "$OSTYPE" == *"msys"* ]]; then
                SSHV_OS=windows
        fi
        if [ -z "$SSHV_OS" ]; then
		echo "Error, could not detect supported operating system to run this installation on. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'."
		exit 1
	fi
fi

# Check to make sure script is running in the correct operating system
SSHV_WRONG_OS=false
case "$SSHV_OS" in
	rhel7)
		SSHV_CURRENT_OS=$( cat /etc/redhat-release )
		if [[ ! "$SSHV_CURRENT_OS" == *"Red Hat Enterprise Linux Server release 7"* ]]; then
			SSHV_WRONG_OS=true
		fi
		SSHV_USER_LOCATION=/home
		SSHV_PATH_FILE_LOCATION=.bash_profile
		;;
	rhel6)
		SSHV_CURRENT_OS=$( cat /etc/redhat-release )
                if [[ ! "$SSHV_CURRENT_OS" == *"Red Hat Enterprise Linux Server release 6"* ]]; then
                        SSHV_WRONG_OS=true
                fi
		SSHV_USER_LOCATION=/home
		SSHV_PATH_FILE_LOCATION=.bash_profile
		;;
	macos)
		SSHV_USER_LOCATION=/Users
		# Create .bash_profile if it does not exist
		if [ ! -f $SSHV_USER_LOCATION/$SSHV_USER/.bash_profile ]; then
			touch $SSHV_USER_LOCATION/$SSHV_USER/.bash_profile
		fi
		SSHV_PATH_FILE_LOCATION=.bash_profile
		;;
	ubuntu16)
		SSHV_CURRENT_OS=$( lsb_release -a )
                if [[ ! "$SSHV_CURRENT_OS" == *"Ubuntu 16"* ]]; then
                        SSHV_WRONG_OS=true
                fi	
		SSHV_USER_LOCATION=/home
		SSHV_PATH_FILE_LOCATION=.profile
		;;
	ubuntu14)
		SSHV_CURRENT_OS=$( lsb_release -a )
                if [[ ! "$SSHV_CURRENT_OS" == *"Ubuntu 14"* ]]; then
                        SSHV_WRONG_OS=true
                fi
		SSHV_USER_LOCATION=/home
		SSHV_PATH_FILE_LOCATION=.profile		
		;;
	windows)
                if [[ ! "$OSTYPE" == *"msys"* ]]; then
                        SSHV_WRONG_OS=true
                fi
                SSHV_USER_LOCATION=/c/Users
                SSHV_PATH_FILE_LOCATION=.bash_profile
		if [[ -z "$SSHV_USER" ]]; then
                        SSHV_USER=$( whoami )
                fi
		if [[ "$SSHV_INSTALL_LOCATION" == *"/usr/local/bin"* ]]; then
                	SSHV_INSTALL_LOCATION=/c/Users/$SSHV_USER/.ssh
                fi
                SSHV_ADD_TO_PATH=true
                ;;
	*)
		echo "Error, invalid os '$SSHV_OS' passed to install script. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
		exit 1
		;;
esac

if [ "$SSHV_WRONG_OS" == true ]; then
	echo "Error, wrong operating system detected. Please be sure the passed operating system matches the one running on the target machine. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
	exit 1
fi

# Check to make sure user has access to location
if [ ! -w $SSHV_INSTALL_LOCATION ]; then
	echo "Error, this script must be run as root to install sshv to '$SSHV_INSTALL_LOCATION'"
	exit 1
fi

# Check to make sure sshv is not already installed
if [ -f "$SSHV_INSTALL_LOCATION/sshv" ] && [ "$SSHV_FORCE_INSTALL" == false ]; then
        echo "Error, sshv already installed to '$SSHV_INSTALL_LOCATION'. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
        exit 1
fi

# Cannot have sshv/ directory in install location already
if [ -d "$SSHV_INSTALL_LOCATION/sshv" ]; then
	echo "Error, 'sshv/' directory already present in install location '$SSHV_INSTALL_LOCATION'. Unable to copy file called 'sshv' to this location. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
        exit 1
fi

SSHV_ALREADY_INSTALLED=$( command -v sshv )
if [ ! -z $SSHV_ALREADY_INSTALLED ] && [ ! -z /usr/local/bin/sshv ] && [ "$SSHV_FORCE_INSTALL" == false ]; then
	if [ "$SSHV_INSTALL_LOCATION/sshv" == $SSHV_ALREADY_INSTALLED ]; then
		echo "Error, sshv already installed to '$SSHV_INSTALL_LOCATION'. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
		exit 1
	else
		if [ ! -z /usr/local/bin/sshv ]; then
			SSHV_ALREADY_INSTALLED=/usr/local/bin/sshv
		fi
		echo "Error, sshv already installed '$SSHV_ALREADY_INSTALLED'. You are trying to install to different location '$SSHV_INSTALL_LOCATION'. It is advised that sshv not be installed in two locations at once and the first be removed before proceeding with this installation. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
		exit 1
	fi
fi

# Get path of current running script since we know sshv executable should always remains next to it in relative directory
SSHV_CURRENT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Copy executable to install location if found
if [ -f "$SSHV_CURRENT_DIR/sshv" ]; then
	cp $SSHV_CURRENT_DIR/sshv $SSHV_INSTALL_LOCATION
else
	echo "Error, could not find sshv executable next to installation script inside of its directory. The executable is downloaded next to the install script and is meant to remain there in order for this script to install it correctly on this machine. Please see install-sshv.sh help page for reference with 'bash install-sshv.sh --help'"
	exit 1
fi

# Change permissions of copied file to make it executable
chmod +x $SSHV_INSTALL_LOCATION/sshv

# Add SSHV_INSTALL_LOCATION to PATH only if flag is set
if [ "$SSHV_ADD_TO_PATH" == true ]; then
	if ! grep -q "PATH=\$PATH:$SSHV_INSTALL_LOCATION" $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
	then
        	echo $'\n# BEGIN - Maintained by sshv - DO NOT ALTER\nPATH=$PATH:'$SSHV_INSTALL_LOCATION >> $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
        	echo 'export PATH'$'\n# END - Maintained by sshv - DO NOT ALTER' >> $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
	fi
	source $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
fi

echo "Installed sshv successfully to $SSHV_INSTALL_LOCATION"

if [ "$SSHV_ADD_TO_PATH" == true ]; then
	echo -e "\nPlease run the following command to update your shell profile and finish the installation:"
	echo -e "\n\tsource ~/$SSHV_PATH_FILE_LOCATION"
fi

