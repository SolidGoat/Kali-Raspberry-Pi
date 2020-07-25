#!/bin/bash

###########################################################
# AUTHOR  : SolidGoat
# DESCR   : Script used to connect to the internet on a
#           Raspberry Pi running Kali with wireless cards
#           that's serving a WiFi access point.
###########################################################

#=========================================================
#Terminal Color Codes
#=========================================================
# Regular Text
txtblk='\e[0;30m' # Black
txtred='\e[0;31m' # Red
txtgrn="\e[0;32m" # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
###############################
# Bold Text
bldblk='\e[1;30m' # Black
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
###############################
# Underline Text
unkblk='\e[4;30m' # Black
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
###############################
# Background Color
bakblk='\e[40m'   # Black
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
###############################
# Rest Color
txtrst='\e[0m'    # Text Reset - Useful for avoiding color bleed

#=================
#Global Variables
#=================
g_iface="wlan1"                                                   #Default value for wlan interface
g_default_gateway="192.168.1.1"                                   #Default value for default gateway
g_wpa_supplicant_config="/etc/wpa_supplicant/wpa_supplicant.conf" ##Default value for wpa_supplicant

# Return to MainMenu
function pause
{
	echo ""
	read -p "Press [Enter] to return to the Main Menu..."
}

# Check if running as root; exit if not
function CheckRoot
{
	if [ $EUID -ne 0 ]
	then
		echo -e ${bldred}"Must run as root."${txtrst}
		exit 0
	fi
}

# Prompt for wlan interface name and wpa_supplicant config location (default values configured)
# If wlan run file is found, delete it
# If wpa_supplicant process is running, kill it
# Then run wpa_supplicant for wlan interface using wpa_supplicant config
# Finally, run dhclient for interface
function ConnectToInternet
{
	echo -e ${txtgrn}"Connecting to Internet..."${txtrst}
	echo ""

	# Prompt for wlan interface name
	read -p "WLAN interface name [$g_iface]: " iface
	iface=${name:-$g_iface} #default interface

	# Prompt for wpa_supplicant config file
	read -p "wpa_supplicant config location [$g_wpa_supplicant_config]: " wpa_supplicant_config
	wpa_supplicant_config=${name:-$g_wpa_supplicant_config} #default config file

	file="/var/run/wpa_supplicant/$iface"

	# If wlan1 run file found, remove file
	if [ -e $file ]
	then
		# Remove wlan1 run file
		echo -e ${txtgrn}"Found..."${txtrst}$file
		echo -e ${txtgrn}"Removing"${txtrst} $file"..."
		rm /var/run/wpa_supplicant/$iface

		# If the wpa_supplicant process is running, kill -9
		if [[ $(ps -ef | grep wpa_supplicant) ]]
		then
			pid=$(ps -ef | grep "wpa_supplicant" | grep -v grep | awk '{print $2}')
			echo -e ${txtylw}"WPA_Supplicant already running...killing PID:$pid"${txtrst}
			kill -9 $pid

			echo ""
		fi

		# Connect to WiFi on specified interface
		echo -e ${txtgrn}"Connecting to WiFi..."${txtrst}
		echo ""

		wpa_supplicant -i $iface -B -c $wpa_supplicant_config

		# Get IP from DHCP
		echo ""
		echo -e ${txtgrn}"Running dhclient on $iface..."${txtrst}
		dhclient $iface

		echo ""
		echo -e ${txtgrn}"$iface IP: "$(ip addr show $iface | grep 'inet' | cut -d':' -f2 | awk '{print $2}')${txtrst}
		echo ""
	else
		# If the wpa_supplicant process is running, kill -9
		if [[ $(ps -ef | grep wpa_supplicant) ]]
		then
			pid=$(ps -ef | grep "wpa_supplicant" | grep -v grep | awk '{print $2}')
			echo -e ${txtylw}"WPA_Supplicant already running...killing $pid"${txtrst}
			#kill -9 $pid
		fi

		# Connect to WiFi on specified interface
		echo -e ${txtgrn}"Connecting to WiFi..."${txtrst}
		echo ""

		wpa_supplicant -i $iface -B -c $wpa_supplicant_config

		# Get IP from DHCP
		echo ""
		echo -e ${txtgrn}"Running dhclient on $iface..."${txtrst}
		dhclient $iface

		echo ""
		echo -e ${txtgrn}"$iface IP: "$(ip addr show $iface | grep 'inet' | cut -d':' -f2 | awk '{print $2}')${txtrst}
		echo ""
	fi

	# Return to MainMenu
	pause
}

# Check if default route exists
# If not, prompt for default gateway IP and wlan interface name (default values configured)
# Then add default gateway route
function ResetDefaultGateway
{
	echo -e ${txtgrn}"Resetting Default Gateway..."${txtrst}
	echo ""
	
	# Check if default route exists
	# If it doesn't, recreate it
	if [[ $(ip route show | grep default) ]]
	then
		echo -e ${txtgrn}"Default route already exists. Nothing to do."${txtrst}
	else
		echo -e ${txtgrn}"No route found."${txtrst}
		echo -e ${txtgrn}"Adding Route..."${txtrst}
		
		# Prompt for default gateway IP address
		read -p "Enter default gateway IP [$g_default_gateway]: " default_gateway
		default_gateway=${name:-$g_default_gateway} #default gateway

		# Prompt for wlan interface name
		read -p "WLAN interface name [$g_iface]: " iface
		iface=${name:-$g_iface} #default interface
		
		route add default gw $default_gateway $iface -v

		echo ""
		echo -e $(ip route show)
	fi

	# Return to MainMenu
	pause
}

# Main Menu
function MainMenu
{
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Connect to Internet"
	echo "2. Reset Default Gateway"
	echo "3. Exit"
	echo ""
}

# Main menu choices
function Choices
{
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) ConnectToInternet ;;
		2) ResetDefaultGateway ;;
		3) exit 0;;
		*) echo -e ${bldred}"Incorrect option."${txtrst} && sleep 2
	esac
}

while true
do
	CheckRoot
	MainMenu
	Choices
done

# Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP