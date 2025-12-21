#!/bin/bash

#userul ar trebui sa fie mereu pe ultima pozitie
USER=""
if [ $(($#%2)) -gt 0 ]; then
	for arg;do
	USER="$arg"
	done
fi

verificare_user(){
if [ -z "$USER" ]; then
	cat #daca nu avem user mentionat nu schimb inputul
else
	while read -r linie;do
		printf "$linie" | grep "$USER"
	done
	#folosesc printf si nu echo pentru ca echo are probleme cu backslash
	#printf si nu cat pentru ca cat nu poate lua din variabila
fi
}
verificare_optiune(){

COMANDA=$1
CONTENT=$2
CONTOR=0
FISIER="/var/log/auth.log" 
if [ "$COMANDA" == "-n" ]; then
                tac /var/log/auth.log | grep -a "session opened" | verificare_user | grep -v "/var/log/auth.log" | head -n "$CONTENT" | while read -r linie; do
                        awk '{ print $1, $2, $9, $11}'
                        CONTOR=$((CONTOR + 1))
                done
        fi      
}

#mai mare ca 1 pentru ca daca ajunge la user pe ultima pozitie sa nu mai intre in while
while [ "$#" -gt 1 ];do
	if [ "$1" = "-n" ] || [ "$1" == "-s" ] || [  "$1" == "-t" ] || [ "$1" == "-p" ]; then
                         verificare_optiune "$1" "$2"  #automat daca avem un option avem si un parametru dupa
        	shift 2
        fi
done
