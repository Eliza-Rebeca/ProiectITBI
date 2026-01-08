#!/bin/bash

n=""
p=""
s=""
t=""

ok=1
        while [ "$ok" -eq 1 ]; do
		ok=0
                if [ "$1" == "-n" ]; then
			if ! [[ "$2" =~ ^[0-9]+$ ]]; then
				echo "Error! Option -n requires a number!"
				echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
				exit 1 
			fi
			 n="$2"
                         shift 2
			 ok=1
		elif [ "$1" == "-p" ]; then
                        if ! [[ "$2" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
				echo "Error! Option -p requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
 			fi
			data="$2"
			if ! [[ "$3" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
				echo "Error! Option -p requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
			fi
			ora="$3"
			if ! date -d "$data $ora" >/dev/null 2>&1; then
				echo "Error! Option -p requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
			fi
			p=$(date -d "$data $ora" +%s 2>/dev/null)
			data=""
			ora=""
                         shift 3
                         ok=1
                elif [ "$1" == "-s" ]; then
                         if ! [[ "$2" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                                echo "Error! Option -s requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
                        fi
                        data="$2"
                        if ! [[ "$3" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
                                echo "Error! Option -s requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
                        fi
                        ora="$3"
                        if ! date -d "$data $ora" >/dev/null 2>&1; then
                                echo "Error! Option -s requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
                        fi
                        s=$(date -d "$data $ora" +%s 2>/dev/null)
                        data=""
                        ora=""
                         shift 3
                         ok=1

   		elif [ "$1" == "-t" ]; then
                         if ! [[ "$2" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                                echo "Error! Option -t requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
                        fi
                        data="$2"
                        if ! [[ "$3" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
                                echo "Error! Option -t requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
                        fi
                        ora="$3"
                        if ! date -d "$data $ora" >/dev/null 2>&1; then
                                echo "Error! Option -t requires a valid date: YYYY-MM-DD and a valid time: HH:MM:SS"
                                echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                                exit 1
                        fi
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
		elif [ -c "/dev/$1" ] || [ -c "/dev/pts/$1" ]; then
			tty=$1
			shift 1
		else
			echo "Error! Introduce a valid user or tty!"
                        echo "Lastb script input: [-n number] [-p YYYY-MM-DD HH-MM-SS] [-s YYYY-MM-DD HH-MM-SS] [-t YYYY-MM-DD HH-MM-SS] [user] [tty]"
                        exit 1
		fi
	done

cnt=0

 zcat -f /var/log/auth.log.4.gz /var/log/auth.log.3.gz /var/log/auth.log.2.gz /var/log/auth.log.1 /var/log/auth.log | tac | grep -a "authentication failure" | grep -v "/var/log/auth.log" | while read -r linie; do
	user_curent=$(echo "$linie" | sed -E 's/.*user=([^ ]+).*/\1/')
	tty_curent=$(echo "$linie" | sed -E 's/.*tty=\/dev\/([^ ]+).*/\1/')
	service_curent=$(echo "$linie" | sed -E 's/.*pam_unix\(([^:]+):auth\).*/\1/')
	data_text=$(echo "$linie" | sed -E 's/^([^ ]+).*/\1/' | sed 's/T/ /; s/\..*+02:00//')
	data_curent=$(date -d "$data_text" +%s)

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
      printf "%-15s %-15s %-8s %s\n" "$user_curent" "$service_curent" "$tty_curent" "$data_text"

    if [ -n "$n" ]; then
        cnt=$((cnt + 1))
        if [ "$cnt" -ge "$n" ]; then
            break
        fi
    fi

done
