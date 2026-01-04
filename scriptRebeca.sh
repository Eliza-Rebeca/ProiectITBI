#!/bin/bash

N=$((2**32-1))
COD=0
CONTOR=0
USER=""
declare -a NAME=()
declare -a METHOD=()
declare -a BEGIN=()
declare -a END=()

verificare_user(){

if [ -z "$USER" ]; then
	cat
else
	grep -aF "$USER"
#F ca string fixat nu ca regex
fi

}

prelucrare(){

    while read -r line; do
        

        if [[ "$line" =~ pam_unix\(gdm-launch-environment:session\):\ session\ opened\ for\ user\ gdm-greeter ]]; then
            #2026-01-01T00:42:29.409797+00:00 Ubuntu25 gdm-launch-environment]: pam_unix(gdm-launch-environment:session): session opened for user gdm-greeter(uid=60578) by (uid=0)
            BEGIN+=("$(echo "$line" | awk '{print $1}')")
            END+=("")
            NAME+=("gdm-greeter")
            METHOD+=("tty1")
            CONTOR=$((CONTOR+1))

        elif [[ "$line" =~ pam_unix\(gdm-launch-environment:session\):\ session\ closed\ for\ user\ gdm-greeter ]]; then
            #2026-01-01T00:43:29.947226+00:00 Ubuntu25 gdm-launch-environment]: pam_unix(gdm-launch-environment:session): session closed for user gdm-greeter
            I=$((CONTOR-1))
            if [ "$I" -ge 0 ];then
            	END[$I]="$(echo "$line" | awk '{print $1}')"
            fi
            
	elif [[ "$line" =~ systemd-logind\[[0-9]+\]:\ New\ session\ [0-9]+\ of\ user ]] && [[ ! "$line" =~ gdm-greeter ]] && [[ ! "$line" =~ root ]]; then
            #2026-01-01T00:43:17.270924+00:00 Ubuntu25 systemd-logind[1132]: New session 2 of user admin.
            # 1                                2        3                    4    5      6 7   8    9
            BEGIN+=("$(echo "$line" | awk '{print $1}')")
            END+=("")
            NAME+=("$(echo "$line" | awk '{print $9}'| sed 's/\.$//')")
            METHOD+=("tty$(echo "$line" | awk '{print $6}')")
            CONTOR=$((CONTOR+1))

        elif [[ "$line" =~ systemd-logind\[[0-9]+\]:\ Session\ [0-9]+\ logged\ out ]] && [[ ! "$line" =~ gdm-greeter ]] && [[ ! "$line" =~ root ]]; then
            #2026-01-01T00:39:22.959322+00:00 Ubuntu25 systemd-logind[1129]: Session 2 logged out. Waiting for processes to exit.
            I=$((CONTOR-1))
            if [ "$I" -ge 0 ];then
            	END[$I]="$(echo "$line" | awk '{print $1}')"
            fi
            
        elif [[ "$line" =~ su\[[0-9]+\]:\ \(to\ root\)\ root\ on ]]; then
            #2026-01-01T00:45:25.422637+00:00 Ubuntu25 su[6035]: (to root) root on pts/1
            BEGIN+=("$(echo "$line" | awk '{print $1}')")
            END+=("")
            NAME+=("root")
            METHOD+=("$(echo "$line" | awk '{print $8}')")
            CONTOR=$((CONTOR+1))

        elif [[ "$line" =~ su\[[0-9]+\]:\ pam_unix\(su:session\):\ session\ closed\ for\ user\ root ]]; then
            #2026-01-01T00:45:25.448198+00:00 Ubuntu25 su[6035]: pam_unix(su:session): session closed for user root
            I=$((CONTOR-1))
            if [ "$I" -ge 0 ];then
            	END[$I]="$(echo "$line" | awk '{print $1}')"
            fi
        fi
    done
}

afisare(){

#echo "$INDEX"
CONTOR=$((CONTOR-1))
for ((i=CONTOR; i>=AUX; i--)); do
    printf "%s %s  " "${NAME[i]}" "${METHOD[i]}"
    printf "%s " "$(date -d "${BEGIN[i]}" +"%a %b %d %H:%M")"
    if [ -z "${END[i]}" ]; then
        printf "still logged in"
    else
        printf "%s  " "$(date -d "${END[i]}" +"%a %b %d %H:%M")"
        #unix epoch time +%s
        end=$( date +%s -d "${END[i]}")
        begin=$( date +%s -d "${BEGIN[i]}")
        time=$(($end - $begin))
        if [ $time -lt 60 ];then
            printf "%s seconds" "$time"
        elif [ $time -lt 86400 ];then
            printf "%s:%s" "$(($time/(3600)))" "$(($time%(60)))"
        else
            days=$(($time/(86400)))
            if [ $days -lt 7 ];then
                printf "%s days" "$days"
            elif [ $days -eq 7 ];then
        	printf "1 week"
            else
                printf "%s weeks" "$(($days/(7)))"
            fi
        fi
    fi
    printf "\n"
done

}

verificare_optiune(){

CONTOR=0
INDEX=0
AUX=0
FISIERE=("/var/log/auth.log"
"/var/log/auth.log.1"
"/var/log/auth.log.2.gz"
"/var/log/auth.log.3.gz"
"/var/log/auth.log.4.gz")


while [ "$N" -gt 0 ] && [ "$INDEX" -lt 5 ]; do

    CONTOR=0
    #cate linii voi gasi in fisierul curent
    OK=0
    prelucrare < <(
    if [ "$INDEX" -lt 2 ];then
        cat "${FISIERE[INDEX]}" \
        | grep -a -v "polkit" \
        | grep -a -v "CRON" \
        | verificare_user
    else
        zcat "${FISIERE[INDEX]}" 2>/dev/null \
        | grep -a -v "polkit" \
        | grep -a -v "CRON" \
        | verificare_user
    fi
    )
   
    INDEX=$((INDEX + 1))
    if [ "$CONTOR" -gt "$N" ];then
    AUX=$((CONTOR - N))
        N=0
    else
    AUX=0
        N=$((N - CONTOR))
    fi  
    afisare
   
done

}

get_input(){

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
if [ "$#" = 1 ] && id "$1" &>/dev/null ; then
USER="$1"
shift 1
else
echo "Eroare de sintaxa"
exit 1
fi
;;
esac
done
}

get_input "$@"
verificare_optiune


