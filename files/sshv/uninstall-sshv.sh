#!/bin/bash

# Synopsis: Uninstalls sshv bash script from machine
# Dependencies: bash
# Author(s):
#   Devon Thyne (devon-thyne)
# Modified: 20190725
# Version: 4.2-000002


##### sshv removal script help
# Syntax:
#   . ./uninstall-sshv.sh [OPTIONS]
#
#
# Options:
#
#   -h or --help : (optional) display help page for sshv uninstall-sshv.sh script
#
#   -l [PATH] or --location [PATH] : (optional) uninstall sshv executable from specific location. Must be absolute path (default (Linux/MacOS): /usr/local/bin, default Windows: /c/Users/<USER>/.ssh/)
#
#   -o [OPERATING SYSTEM] or --os [OPERATING SYSTEM] : (optional) manually configures script to uninstall sshv from the passed operating system. Default behavior is to scan list of supported Operating Systems and uninstall from detected platform. 
#     Options:
#       rhel7 : Red Hat Enterprise Linux 7
#       rhel6 : Red Hat Enterprise Linus 6
#       macos : Mac OS
#       ubuntu16 : Ubuntu 16
#       ubuntu14 : Ubuntu 14
#       windows : Windows
#
#   -u [USER] or --user [USER] : (optional), remove install location from environment variable PATH for specific user. Cannot be root. By default, Windows installation will auto-detect this value.
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

# Default do not remove install location from PATH
SSHV_REMOVE_FROM_PATH=false



# Traverse option flags input as command line arguments
while [ ! $# -eq 0 ]
do
	case "$1" in
		-h | --help)
			echo -e "Help Page - sshv uninstall-sshv.sh\n\nScript to uninstall 'sshv' command\n\n\nSyntax:\n\n\tbash uninstall-sshv.sh [OPTIONS]\n\n\nOptions:\n\n\t-h or --help : (optional) display help page for sshv uninstall-sshv.sh script\n\n\t-l [PATH] or --location [PATH] : (optional) uninstall sshv executable from specific location. Must be absolute path. (default (Linux, MacOS): /usr/local/bin, default Windows: /c/Users/<USER>/.ssh/)\n\n\t-o [OPERATING SYSTEM] or --os [OPERATING SYSTEM] : (optional) manually configures script to uninstall sshv from the passed operating system. Default behavior is to scan list of supported Operating Systems and uninstall from detected platform.\n\t\tOptions:\n\t\t\trhel7 : Red Had Enterprise Linux 7\n\t\t\trhel6 : Red Hat Enterprise Linux 6\n\t\t\tmacos : Mac OS\n\t\t\tubuntu16 : Ubuntu 16\n\t\t\tubuntu14 : Ubuntu 14\n\t\t\twindows : Windows\n\n\t-u [USER] or --user [USER] : (optional) remove install location from environment variable PATH for specific user. Cannot be root. By default, Windows installation will auto-detect this value.\n\n\nDependencies:\n\n\tAll Platforms:\n\t\t- vault cli\n\n\tMacOS:\n\t\t- brew\n\n\tWindows:\n\t\t- git bash"
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
			SSHV_REMOVE_FROM_PATH=true
			SSHV_USER=$1
			if [ ! -d "/home/$SSHV_USER" ]; then
          			echo "Error, passed user does not exist on this machine. Please see uninstall-sshv.sh hep page for reference with 'bash uninstall-sshv.sh --help'."
				exit 1
			fi
			;;
		*)
			echo "Error, invalid flag '$1' passed to removal script. Please see uninstall-sshv.sh help page for reference with 'bash uninstall-sshv.sh --help'."
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
                echo "Error, could not detect supported operating system to run this uninstallation on. Please see uninstall-sshv.sh help page for reference with 'bash uninstall-sshv.sh --help'."
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
                SSHV_REMOVE_FROM_PATH=true
		;;
	*)
		echo "Error, invalid os '$SSHV_OS' passed to uninstall script. Please see uninstall-sshv.sh help page for reference with 'bash uninstall-sshv.sh --help'"
		exit 1
		;;
esac

if [ "$SSHV_WRONG_OS" == true ]; then
	echo "Error, wrong operating system detected. Please be sure the passed operating system matches the one running on the target machine. Please see uninstall-sshv.sh help page for reference with 'bash uninstall-sshv.sh --help'"
	exit 1
fi

# Check to make sure user has access to location
if [ ! -w $SSHV_INSTALL_LOCATION ]; then
	echo "Error, this script must be run as root to uninstall sshv from '$SSHV_INSTALL_LOCATION'"
	exit 1
fi

# Remove executable from install location
if [ -f $SSHV_INSTALL_LOCATION/sshv ]; then
	rm $SSHV_INSTALL_LOCATION/sshv
	SSHV_FILE_NOT_EXIST=false
else
	SSHV_FILE_NOT_EXIST=true
fi

# Remove SSHV_INSTALL_LOCATION from PATH only if flag was set
if [ "$SSHV_REMOVE_FROM_PATH" == true ]; then
	if grep -q "PATH=\$PATH:$SSHV_INSTALL_LOCATION" $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
	then
		COUNT=1
		NEXT_LINE=false
		while IFS= read -r line
		do
			if [ "$line" == "# BEGIN - Maintained by sshv - DO NOT ALTER" ]; then
				sed -i "${COUNT}d" $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
				sed -i "${COUNT}d" $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
				sed -i "${COUNT}d" $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
				sed -i "${COUNT}d" $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
				break
			fi
			COUNT=$((COUNT + 1))
		done < $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
		if [ "$SSHV_FILE_NOT_EXIST" == true ]; then
			echo "Could not find sshv executable in '$SSHV_INSTALL_LOCATION' but was able to remove path from $SSHV_USER's PATH environment variable."
			exit 0
		fi
	else
		if [ "$SSHV_FILE_NOT_EXIST" == false ]; then
			echo "Removed sshv executable from '$SSHV_INSTALL_LOCATION' but could not find path to remove from $SSHV_USER's PATH environment variable."
			exit 0
		else
			echo "Error, Could not find sshv executable in '$SSHV_INSTALL_LOCATION' and could not find path to remove from $SSHV_USER's PATH environment variable."
			exit 1
		fi
	fi
	source $SSHV_USER_LOCATION/$SSHV_USER/$SSHV_PATH_FILE_LOCATION
fi

if [ "$SSHV_FILE_NOT_EXIST" == false ]; then
	echo "Uninstalled sshv successfully from $SSHV_INSTALL_LOCATION"
else
	echo "Could not find sshv executable in $SSHV_INSTALL_LOCATION"
fi

