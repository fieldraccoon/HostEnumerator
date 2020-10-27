#!/bin/bash

PATH_TO_NMAP_PARSE_OUTPUT="/opt/nmap-parse-output/nmap-parse-output"


RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'

cat << 'BANNEREND'
 _     _                  _____
| |   (_)_ __  _   ___  _| ____|_ __  _   _ _ __ __
| |   | | '_ \| | | \ \/ /  _| | '_ \| | | | '_ ` _ \
| |___| | | | | |_| |>  <| |___| | | | |_| | | | | | |
|_____|_|_| |_|\__,_/_/\_\_____|_| |_|\__,_|_| |_| |_|
BANNEREND

echo "$banner"

if [ "$EUID" -ne 0 ]
then
        echo -e "${RED}YOU MUST RUN THIS AS ROOT OR SOME SCANS MIGHT NOT WORK!"
else
        echo -e "${RED}YOU ARE RUNNING AS ROOT!"
fi

if [ ! -d "enum" ]
then
        mkdir -p enum{/dirs,/ports,/misc,/smb}
else 
        rm -r enum; mkdir -p enum{/dirs,/ports,/misc,/smb}
fi


usage()
{
	echo -e "Usage ./Enumerator.sh -i ip [options]"
	echo -e "Options are:"
	echo -e "	-i 		The host that you are scanning"
	echo -e "	-p 		The port you would like to scan on."
	echo -e "	-w= 		Which wordlist you would like to use."
	echo -e "	-h		Lists Help options"
}



# adding colors and other variables
function get_wordlist() 
{
    local FLAG="-w="
    local ARGS=${@}

    for arg in $ARGS
    do
        if [[ $arg == $FLAG* ]]; then
            echo "${arg#$FLAG}"
            return
    fi
    done

}


prewordlist=$(get_wordlist "$@")

if [[ "$prewordlist" == ""  ]]
then
        wordlist=/usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt
else
        wordlist=$(get_wordlist "$@")
fi

echo -e "${GREEN}[+]${BLUE} You are using wordlist $wordlist"



smbmap(){
    IFS=',' read -r -a array <<< $OPEN_PORTS

    if [[ " ${array[@]} " =~ "445" ]]; then
            smbmap -H $rhost > enum/smb/smbmap_$rhost.txt
	    echo $'\n'  | tee -a $SUMOUT
	    echo -e "You can try connecting to smb with smbclient with the following command without credentials." |  tee -a $SUMOUT
	    echo -e "smbclient -L $rhost"
	    echo $'\n' | tee -a $SUMOUT
	    echo -e "smbclient //$rhost/SHARE or smbclient -U "username" //$rhost/SHARE "
    fi
}

function nikto_scan_port()
{
if [[ $rhost == "" ]] && [[ $rport == "" ]]
then
	usage
else
        nikto --host http://$rhost --port $rport > enum/misc/nikto-scan-$rhost-$rport.txt

fi
}

function port_os_detection()
{
if [[ $rhost == ""  ]] && [[ $rport == ""  ]]
then 
	usage
else
        nmap -O -Pn -p $rport -o enum/misc/$rhost-$rport-OS.txt $rhost
fi
}

function simple_port_directories()
{
if [[  $rhost == ""  ]]
then
	usage
else
        gobuster dir -w $wordlist -u http://$rhost:$rport/ -o enum/dirs/gobuster-$rhost-$rport.txt
fi
}

# vhosts for port and ip

function simple_vhosts_port()
{
if [[  $rhost == ""  ]] && [[ $rport == ""  ]]
then
	usage
else
        gobuster vhost -u http://$rhost:$rport/ -w $wordlist > enum/misc/gobuster_vhosts_$rhost-$rport.txt
fi
}

function advanced_nmap_port()
{

if [[ $rhost == "" ]] && [[ $rport == "" ]]
then
	usage
else
        nmap -A -sC -sV -Pn -p $rport -o enum/ports/advanced-nmap-$rhost-port-$rport.txt $rhost
fi
}

# nmap scan with verbose mode

function simple_ports()
{
if [[  $rhost == ""  ]]
then
	usage
else
        nmap -sC -sV -Pn -o enum/ports/nmap.txt $rhost
fi

}


function simple_directories()
{
if [[  $rhost == ""  ]]
then
	usage
else
        gobuster dir -w $wordlist -u http://$rhost/ > enum/dirs/gobuster-$rhost.txt
fi
}



function simple_vhosts()
{
if [[  $rhost == ""  ]]
then
	usage
else
        gobuster vhost -u http://$rhost/ -w $wordlist > enum/misc/gobuster-$rhost-vhosts.txt
fi
}

function simple_nikto_scan()
{
if [[  $rhost == ""  ]]
then
	usage
else
        nikto -h http://$rhost > enum/misc/nikto-$rhost.txt
fi
}

function advanced_nmap()
{
if [[  $rhost == ""  ]]
then
	usage
else
        nmap -A -O -sC -sV -Pn -o enum/misc/advanced-nmap-$rhost-scan.txt $rhost
fi
}

function advanced_nmap_port()
{
if [[ $rhost == "" ]] && [[ $rport == "" ]]
then
	usage
else
        nmap -A -O -sC sV -Pn -p $rport -o enum/misc/advanced-nmap-$rhost-port-$rport.txt $rhost
fi
}


nmap_version_openports()
{
	
echo -e "${GREEN}[*]${BLUE} Running scans on open ports${NC}"
	nmap -sS -sV  -p$OPEN_PORTS -oN enum/ports/nmap_version-$rhost.txt -oX enum/nmap_version.xml $rhost

	if test -f nmap-$rhost-services-output.txt; then
	    	rm nmap-$rhost-services-output.txt
	    	touch nmap-$rhost-services-output.txt
	fi

	if test -f summary.txt; then
			rm summary.txt
			touch summary.txt
	fi
	   
	echo "###################### PORT INFO #########################################" | tee $SUMOUT
    IFS=',' read -r -a array <<< $OPEN_PORTS

    for port in ${array[@]}
    do
        echo $(${PATH_TO_NMAP_PARSE_OUTPUT} enum/nmap_version.xml port-info ${port}) >> $SUMOUT
    done
    echo "##########################################################################" | tee -a $SUMOUT

    echo $'\n'  | tee -a $SUMOUT

    echo "###################### HTTP PORTS #########################################" | tee -a $SUMOUT
    echo $(${PATH_TO_NMAP_PARSE_OUTPUT} enum/nmap_version.xml http-ports) | tee -a $SUMOUT
    echo "##########################################################################" | tee -a $SUMOUT

    echo $'\n'  | tee -a $SUMOUT

    echo "###################### SERVICE NAMES ######################################" | tee -a $SUMOUT
    echo $(${PATH_TO_NMAP_PARSE_OUTPUT} enum/nmap_version.xml service-names) | tee -a $SUMOUT
    echo "###########################################################################" | tee -a $SUMOUT

    echo $'\n' | tee -a $SUMOUT

    echo "###################### PRODUCTS ###########################################" | tee -a $SUMOUT
    echo $(${PATH_TO_NMAP_PARSE_OUTPUT} enum/nmap_version.xml product) | tee -a $SUMOUT
    echo "###########################################################################" | tee -a $SUMOUT

}



while getopts i:p:h: flags
do
        case "${flags}" in
                i) 
                        rhost=${OPTARG}
		        SUMOUT="enum/summary-$rhost.txt";;

                p) 
                    rport=${OPTARG}

                        echo -e "${GREEN}[+]${BLUE} Loading tools..."
                        echo -e "${GREEN}[+]${BLUE} Scanning with nmap"
                        echo -e "${GREEN}[+]${BLUE} Scanning with nikto"
                        echo -e "${GREEN}[+]${BLUE} Scanning Operating systems"
                        echo -e "${GREEN}[+]${BLUE} Scanning Virtul hosts"
                        echo -e "${GREEN}[+]${BLUE} Scanning Directories"
                        simple_port_directories | advanced_nmap_port | nikto_scan_port | port_os_detection | simple_vhosts_port
                        echo -e "${GREEN}[+]${RED} ALL SCANS HAVE FINISHED RUNNING!";;
		h)
			usage;;

                esac
done


echo $rhost
nmap -Pn -oX enum/nmap.xml -T4 $rhost

# nmap scan with verbose mode
OPEN_PORTS=$(${PATH_TO_NMAP_PARSE_OUTPUT} enum/nmap.xml ports)

if [[ ! -z $"OPEN_PORTS"  ]]
then 
	nmap_version_openports
else
	echo "version scan not working"
fi
	



if [[ $rport == "" ]]
then

        echo -e "${GREEN}[+]${BLUE} Loading tools..."
        echo -e "${GREEN}[+]${BLUE} Scanning with nmap"
        echo -e "${GREEN}[+]${BLUE} Scanning with nikto"
        echo -e "${GREEN}[+]${BLUE} Scanning Operating systems"
        echo -e "${GREEN}[+]${BLUE} Scanning Virtul hosts"
        echo -e "${GREEN}[+]${BLUE} Scanning Directories${NC}" 
#       echo -e "Something went wrong maybe"
        simple_ports | simple_directories | simple_vhosts | simple_nikto_scan | advanced_nmap | smbmap
fi
