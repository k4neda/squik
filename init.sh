#!/bin/bash

NC='\033[0m'
RED="\E[0;41m\033[1m"
ORANGE="\E[30;43m\033[30m"
GREEN="\E[30;42m\033[30m"
FONTGREEN="\033[0;32m"

CONNECTION="0"
SQLMAP="0"
NMAP="0"
TOR="0"


function main(){
	echo -e  "\033[2J\033[0;1H"
	echo -e  "\t\t     ___       __        _______   ";
	echo -e  "\t\t     | |      /  \\      |  _____| ";
	echo -e  "\t\t     | |     / /\ \\     | |_____  ";
	echo -e  "\t\t     | |    / /__\ \\    |_____  | ";
	echo -en "\t\t     | |   / _____  \\    _____| | "; initstatus $CONNECTION internet
	echo -en "\t\t     | |  / /      \ \\  |       | "; initstatus $SQLMAP sqlmap
	echo -en "\t\t     ############################  "; initstatus $NMAP nmap
	echo -en "\t\t        increased attack speed     "; initstatus $TOR tor
	echo -e  ""
	echo -e  "${FONTGREEN}----------------------------------------------------------------------${NC}"
	echo -e  "Target: <URL>"
	echo -e  ""
	echo -e  ""

	
}

function init(){
		
	#ping 8.8.8.8
	ping -q -c 3 8.8.8.8
	if [ $? == "0" ]; then
		echo -e "\033[2J\033[0;1H"
		echo -e "${GREEN}[!]${NC} connection ok"
		CONNECTION="1"
	else
		echo -e "\033[2J\033[0;1H"	
		echo -e "${RED}[critical]${NC} connection failed"
		CONNECTION="0"
	fi
	
	#check nmap
	bincheck nmap
	
	#check sqlmap
	bincheck sqlmap
	
	#check tor
	service tor status 1>/dev/null
	if [ $? == "0" ]; then
		echo -e "${GREEN}[!]${NC} tor service running"
		TOR="1"
	else
		which tor 1>/dev/null
		if [ $? == "0" ]; then
			echo -e "${ORANGE}[warning]${NC} tor detected but not running"
			TOR="2"
		else
			echo -e "${RED}[critical]${NC} tor not found"
		fi
	fi
}

function bincheck()
{
	which $1 1>/dev/null
	if [ $? == "0" ]; then
		echo -e "${GREEN}[!]${NC} $1 detected"
		
		if [ $1 == "nmap" ]; then
			NMAP=1
		elif [ $1 == "sqlmap" ]; then
			SQLMAP=1
		fi
	else
		echo -e "${RED}[critical]${NC} $1 not found"
	fi
}

function initstatus()
{
	if [ "$1" == "0" ]; then
		echo -e "\t[${RED}  ${NC}] $2"
	elif [ $1 == "1" ]; then
		echo -e "\t[${GREEN}  ${NC}] $2"
	elif [ $1 == "2" ]; then
		echo -e "\t	[${ORANGE}  ${NC}] $2"
	fi	
	
}

init
#read -n 1 -s 
main
