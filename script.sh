#!/bin/bash

n=0
p=0
s=0
t=0

verificare_optiune(){

COMANDA=$1
CONTENT=$2

        if [ "$COMANDA" == "-n" ]; then
                zcat -f /var/log/auth.log.4.gz /var/log/auth.log.3.gz /var/log/auth.log.2.gz /var/log/auth.log.1 /var/log/auth.log | tac | grep -a "authentication failure" | grep -v "/var/log/auth.log" | head -n "$CONTENT" | sed -E 's/^([^ ]+).*gdm-password\]:.*tty=\/dev\/([^ ]+).*user=([^ ]+)/\3 gdm-password \2 \1/' | sed 's/T/ /; s/\..*+02:00//'
                
        fi
}

ok=0
        while [ "$#" -gt 0 ]; do

                if [ "$1" == "-n" ]; then
			 n=1
                         shift 1
			 ok=1
		elif [ "$1" == "-p" ]; then
                         p=1
                         shift 1
                         ok=1
                elif [ "$1" == "-s" ]; then
                         s=1
                         shift 1
                         ok=1
   		elif [ "$1" == "-t" ]; then
                         t=1
                         shift 1
                         ok=1
                fi

	if [ "$n" -eq 1 ]; then
		verificare_optiune "-n" "$1"
		shift 1
	fi
done
	if [ "$ok" -eq 0 ]; then
	zcat -f /var/log/auth.log.4.gz /var/log/auth.log.3.gz /var/log/auth.log.2.gz /var/log/auth.log.1 /var/log/auth.log | tac | grep -a "authentication failure" | grep -v "/var/log/auth.log" | sed -E 's/^([^ ]+).*gdm-password\]:.*tty=\/dev\/([^ ]+).*user=([^ ]+)/\3 gdm-password \2 \1/' | sed 's/T/ /; s/\..*+02:00//'
fi

