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
 
    else
            echo "[ERROR] No Standard SMB ports found."
    fi
}

function nikto_scan_port()
{
if [[ $rhost == "" ]] && [[ $rport == "" ]]
then
        echo "Sorry you have not specified your host. Please use the -i and the -p option"
else
        nikto --host $rhost --port $rport > enum/misc/nikto-scan-$rhost-$rport.txt

fi
}

function port_os_detection()
{
if [[ $rhost == ""  ]] && [[ $rport == ""  ]]
then 
        echo "Sorry you have not specified your host. Please use the -i and the -p option."
else
        nmap -O -Pn -p $rport -o enum/misc/$rhost-$rport-OS.txt $rhost
fi
}

function simple_port_directories()
{
if [[  $rhost == ""  ]]
then
        echo "sorry you have not specified your host. please use the -i option."
else
        gobuster dir -w $wordlist -u http://$rhost:$rport/ -o enum/dirs/gobuster-$rhost-$rport.txt
fi
}

# vhosts for port and ip

function simple_vhosts_port()
{
if [[  $rhost == ""  ]] && [[ $rport == ""  ]]
then
        echo "sorry you have not specified your host. please use the -i option."
else
        gobuster vhost -u http://$rhost:$rport/ -w $wordlist > enum/misc/gobuster_vhosts_$rhost-$rport.txt
fi
}

function advanced_nmap_port()
{

if [[ $rhost == "" ]] && [[ $rport == "" ]]
then
        echo "Sorry you have not specified your host. Please use the -i and the -p option"
else
        nmap -A -sC -sV -Pn -p $rport -o enum/ports/advanced-nmap-$rhost-port-$rport.txt $rhost
fi
}

while getopts i:p:a: flags
do
        case "${flags}" in
                i) 
                        rhost=${OPTARG};;

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
                a) advanced=${OPTARG};;

                esac
done


echo $rhost

# nmap scan with verbose mode

function simple_ports()
{
if [[  $rhost == ""  ]]
then
        echo "sorry you have not specified your host. please use the -i option."
else
        nmap -sC -sV -Pn -o enum/ports/nmap.txt $rhost
fi

}


function simple_directories()
{
if [[  $rhost == ""  ]]
then
        echo "sorry you have not specified your host. please use the -i option."
else
        gobuster dir -w $wordlist -u http://$rhost/ > enum/dirs/gobuster-$rhost.txt
fi
}



function simple_vhosts()
{
if [[  $rhost == ""  ]]
then
        echo "sorry you have not specified your host. please use the -i option."
else
        gobuster vhost -u http://$rhost/ -w $wordlist > enum/misc/gobuster-$rhost-vhosts.txt
fi
}

function simple_nikto_scan()
{
if [[  $rhost == ""  ]]
then
        echo "sorry you have not specified your host. please use the -i option."
else
        nikto -h $rhost > enum/misc/nikto-$rhost.txt
fi
}

function advanced_nmap()
{
if [[  $rhost == ""  ]]
then
        echo "Sorry you have not specified your host. Please use the -i option."
else
        nmap -A -O -sC -sV -Pn -o enum/misc/advanced-nmap-$rhost-scan.txt $rhost
fi
}

function advanced_nmap_port()
{
if [[ $rhost == "" ]] && [[ $rport == "" ]]
then
        echo "Sorry you have not specified your host. Please use the -i and the -p option"
else
        nmap -A -O -sC sV -Pn -p $rport -o enum/misc/advanced-nmap-$rhost-port-$rport.txt $rhost
fi
}




if [[ $rport == "" ]]
then

        echo -e "${GREEN}[+]${BLUE} Loading tools..."
        echo -e "${GREEN}[+]${BLUE} Scanning with nmap"
        echo -e "${GREEN}[+]${BLUE} Scanning with nikto"
        echo -e "${GREEN}[+]${BLUE} Scanning Operating systems"
        echo -e "${GREEN}[+]${BLUE} Scanning Virtul hosts"
        echo -e "${GREEN}[+]${BLUE} Scanning Directories${NC}" 
#       echo -e "Something went wrong maybe"
        nmap -Pn -oX enum/nmap.xml -T4 $rhost | simple_ports | simple_directories | simple_vhosts | simple_nikto_scan | advanced_nmap 
fi

OPEN_PORTS=$(${PATH_TO_NMAP_PARSE_OUTPUT} enum/nmap.xml ports)

smbmap

if [[  -z "$(cat enum/smb/smbmap_$rhost.txt | grep ":445")"  ]]
    then
            echo -e "${BLUE}[+] PORT 445 IS OPEN YOU CAN CONNECT WITH SMB${NC}"
    else
            echo -e "${RED}PORT 445 IS CLOSED${NC}"
fi
