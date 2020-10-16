# Linux Enumerator

This is a simple bash script that takes an ip and/or a port and performs lots of scans on it that automates the process of enumeration.

## Setup:

```
git clone https://github.com/fieldraccoon/LinuxEnumerator.git
cd LinuxEnumerator
./install.sh
```
## Running it

```bash
sudo ./file.sh -i 10.10.10.211 -p 8000                                                                                                                                                                                             3 ⚙
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
```

## Examples

```bash
./file.sh -i 10.10.10.211 -p 8000
```

```bash
./file.sh -i 10.10.10.211
```
```bash
./file.sh -i 10.10.10.211 -w=/use/share/wordlists/dirbuster/commmon.txt
```
## Output
  
#### This outputs all your scans into a neat /enum directory with all the scans organized.
  
  ```bash
  $ ls *                                                                                                                         2 ⚙
dirs:
wfuzz-10.10.10.211.txt

misc:
10.10.10.211-8000-OS.txt  gobuster-vhosts-10.10.10.211-8000.txt  nikto-scan-10.10.10.211-8000.txt

ports:
advanced-nmap-10.10.10.211-port-8000.txt
```


