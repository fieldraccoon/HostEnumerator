#!/bin/bash

sudo apt install gobuster wfuzz ffuf nmap nikto smbmap
cd /opt 
git clone https://github.com/ernw/nmap-parse-output.git
chmod +x /opt/nmap-parse-output/nmap-parse-output


