#!/bin/bash

n=""
p=""
s=""
t=""

ok=1
        while [ "$ok" -eq 1 ]; do
		ok=0
                if [ "$1" == "-n" ]; then
			 n="$2"
                         shift 2
			 ok=1
		elif [ "$1" == "-p" ]; then
                         data="$2"
			 ora="$3"
			p=$(date -d "$data $ora" +%s 2>/dev/null)
			data=""
			ora=""
                         shift 3
                         ok=1
                elif [ "$1" == "-s" ]; then
                         data="$2"
                         ora="$3"
                        s=$(date -d "$data $ora" +%s 2>/dev/null)
                        data=""
                        ora=""
			shift 3
                         ok=1
   		elif [ "$1" == "-t" ]; then
                         data="$2"
                         ora="$3"
                        t=$(date -d "$data $ora" +%s 2>/dev/null)
                        data=""
                        ora=""
                        shift 3
                         ok=1

                fi
done

user=""
tty=""
	while [ "$#" -gt 0 ]; do

		if id "$1" >/dev/null 2>&1; then
			user=$(id -un "$1")
			shift 1
		elif [ -c "/dev/$1" ]; then
			tty=$1
			shift 1
		fi

	done

cnt=0

 zcat -f /var/log/auth.log.4.gz /var/log/auth.log.3.gz /var/log/auth.log.2.gz /var/log/auth.log.1 /var/log/auth.log | tac | grep -a "authentication failure" | grep -v "/var/log/auth.log" | while read -r linie; do
	user_curent=$(echo "$linie" | sed -E 's/.*user=([^ ]+).*/\1/')
	tty_curent=$(echo "$linie" | sed -E 's/.*tty=\/dev\/([^ ]+).*/\1/')
	service_curent=$(echo "$linie" | sed -E 's/.*pam_unix\(([^:]+):auth\).*/\1/')
	data_text=$(echo "$linie" | sed -E 's/^([^ ]+).*/\1/' | sed 's/T/ /; s/\..*+02:00//')
	data_curent=$(date -d "$data_text" +%s)


    if [ -n "$n" ]; then
        cnt=$((cnt + 1))
        if [ "$cnt" -gt "$n" ]; then
            break
        fi
    fi

    if [ -n "$p" ]; then
        if [ "$p" -ne "$data_curent" ]; then
            continue
        fi
    fi

    if [ -n "$s" ] && [ -n "$t" ]; then
        if [ "$data_curent" -le "$s" ] || [ "$data_curent" -gt "$t" ]; then
            continue
        fi
    elif [ -n "$s" ]; then
        if [ "$data_curent" -le "$s" ]; then
            continue
        fi
    elif [ -n "$t" ]; then
        if [ "$data_curent" -gt "$t" ]; then
            continue
        fi
    fi

    if [ -n "$user" ]; then
        if [ "$user" != "$user_curent" ]; then
            continue
        fi
    fi

    if [ -n "$tty" ]; then
        if [ "$tty" != "$tty_curent" ]; then
            continue
        fi
    fi
     echo "$user_curent $service_curent $tty_curent $data_text" | column -t
done
