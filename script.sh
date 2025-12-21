#!/bin/bash

verificare_optiune(){

COMANDA=$1
CONTENT=$2
        if [ "$COMANDA" == "-n" ]; then
                tac /var/log/auth.log | grep -a "authentication failure" | grep -v "/var/log/auth.log" | head -n "$CONTENT" | while read -r linie; do
                        echo -e "${linie:179:10}\t${linie:55:12}\t${linie:154:4}\t${linie:0:10} ${linie:11:8}"
                done
        fi
}

        while [ "$#" -gt 0 ]; do

                if [[ "$1" == "-n" || "$1" == "-s" || "$1" == "-t" || "$1" == "-p" ]]; then
                         verificare_optiune "$1" "$2"  #automat daca avem un option avem si un parametru dupa
                         shift 2
                fi
        done

