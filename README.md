# Host Enumerator

This is a simple bash script that takes an ip and/or a port and performs lots of scans on it that automates the process of enumeration.

## Setup:

```
git clone https://github.com/fieldraccoon/HostEnumerator.git
cd HostEnumerator
./install.sh
```

## Services it detects so far
- Smb

## Running it

```bash
sudo ./file.sh -i 10.10.10.211                                                                                                                                                                                            3 ⚙
YOU ARE RUNNING AS ROOT!

 _     _                  _____
| |   (_)_ __  _   ___  _| ____|_ __  _   _ _ __ __
| |   | | '_ \| | | \ \/ /  _| | '_ \| | | | '_ ` _ \
| |___| | | | | |_| |>  <| |___| | | | |_| | | | | | |
|_____|_|_| |_|\__,_/_/\_\_____|_| |_|\__,_|_| |_| |_|


[+] Loading tools...
[+] Scanning with nmap                                                                                                                                                                                                                     
[+] Scanning with nikto                                                                                                                                                                                                                    
[+] Scanning Operating systems                                                                                                                                                                                                             
[+] Scanning Virtul hosts                                                                                                                                                                                                                  
[+] Scanning Directories 
[+] PORT 445 IS OPEN YOU CAN CONNECT WITH SMB
```

## Examples


```bash
./Enumerator.sh -i 10.10.10.211
```
```bash
./Enumerator.sh -i 10.10.10.211 -w=/usr/share/wordlists/dirbuster/commmon.txt
```
## Output
  
#### This outputs all your scans into a neat /enum directory with all the scans organized.
  
  ```bash
  $ ls *                                                                                                                         2 ⚙
nmap_version.xml  nmap.xml  summary-10.10.10.214.txt

dirs:
gobuster-10.10.10.214.txt

misc:
advanced-nmap-10.10.10.214-scan.txt  gobuster-10.10.10.214-vhosts.txt  nikto-10.10.10.214.txt

ports:
nmap.txt  nmap_version-10.10.10.214.txt

```

Outputs a Summary file with all the important information you might need including example commands, services and more


