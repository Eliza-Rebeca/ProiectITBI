#!/bin/bash


N=$((2**32-1))
COD=0
USER=""

verificare_user(){
if [ -z "$USER" ]; then
	cat #daca nu avem user mentionat nu schimb inputul
else
	while read -r linie;do
		printf "$linie" | grep -F "$USER"
	done
	#folosesc printf si nu echo pentru ca echo are probleme cu backslash
	#printf si nu cat deoarece cat nu poate lua din variabila
	#F ca string fixat nu ca regex
fi
}

afisare(){

awk '{ print $1, $3, $9, $11 }'

}

verificare_optiune(){

CONTOR=0
INDEX=0
FISIERE=("/var/log/auth.log"
	"/var/log/auth.log.1" 
	"/var/log/auth.log.2.gz"
	"/var/log/auth.log.3.gz"
	"/var/log/auth.log.4.gz")

while [ "$N" -gt 0 ] && [ "$INDEX" -lt 5 ]; do

    CONTOR=0
    if [ "$INDEX" -lt 2 ]; then
        while read -r linie; do
            printf "%s\n" "$linie" | afisare 
            CONTOR=$((CONTOR + 1))
        done < <(
            tac "${FISIERE[INDEX]}" \
            | grep "session opened" 2>/dev/null \
            | verificare_user \
            | head -n "$N"
        )
    else
        while read -r linie; do
            printf "%s\n" "$linie" | afisare
            CONTOR=$((CONTOR + 1))
        done < <(
            gunzip -c "${FISIERE[INDEX]}" \
            | tac \
            | grep "session opened" 2>/dev/null \
            | verificare_user \
            | head -n "$N"
        )
    fi
    
    N=$((N - CONTOR))
    INDEX=$((INDEX + 1))
    #echo "$N" "$INDEX" "$CONTOR"
    
done
}

#codificare de tip present_till_since
while [ "$#" -gt 0 ];do
	case "$1" in 
	-n)
		N=$2
		#nu encodez in comanda -n, daca nu e apelat ramane int_max
		shift 2
	;;
	-s)
		COD=$((COD+(1<<0)))
		shift 2
	;;
	-t)
		COD=$((COD+(1<<1)))
		shift 2
	;;
	-p)
		COD=$((COD+(1<<2)))
		shift 2
	;;
	*)
		if [ "$#" = 1 ] && [ id "$1" &>/dev/null ] ; then
			USER="$1"
			shift 1
		else
			echo "Eroare de sintaxa" 
			exec exit 1
		fi
	;;
	esac
done

verificare_optiune 
