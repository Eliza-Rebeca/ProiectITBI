# MyLast

## Team Members

* Eliza-Georgiana Boroș
* Rebeca Nicula

## Overview

MyLast consists of two Linux shell scripts that emulate the behavior of the last and lastb commands:

* last.sh displays successful login sessions

* lastb.sh displays failed login attempts

## Supported Flags

The script supports the following options:

* -n <number>
  Limit the output to the first **n** entries.

* -s <time>
  Show sessions starting **since** the specified time or date.

* -t <time>
  Show sessions **until** the specified time or date.

* -p <present>
  Show sessions that were present at the specified time.

Flags can be combined depending on the script logic.

## Usage


sh 
```
./last.sh [options][user]
./lastb.sh [options][user][tty]
```

### Examples


sh
```
./last.sh -n 5
./last.sh -s 2025-01-01
./lastb.sh -t 2025-01-31 12:00:00
./lastb.sh -p 2025-09-10 12:00:00
./last.sh alice
./lastb.sh ana tty3
```


## Requirements

* Linux operating system
* Bash shell 
* Access to system login records (such as /var/log/auth.log[1-4])

# MyLast

## Membrii echipei

* Eliza-Georgiana Boroș
* Rebeca Nicula

## Prezentare generală

MyLast constă din două scripturi shell Linux care emulează comportamentul comenzilor `last` și `lastb`:

* `last.sh` afișează sesiunile de autentificare reușite

* `lastb.sh` afișează încercările de autentificare eșuate

## Opțiuni 

Scriptul oferă următoarele opțiuni:

* `-n <number>`
  Limitează afișarea la primele **n** înregistrări.

* `-s <time>`
  Afișează sesiunile care au început **din** momentul sau data specificată.

* `-t <time>`
  Afișează sesiunile **până la** momentul sau data specificată.

* `-p <present>`
  Afișează sesiunile care erau active la momentul specificat.

Opțiunile pot fi combinate în funcție de logica scriptului.

## Utilizare

sh
```
./last.sh [opțiuni][utilizator]
./lastb.sh [opțiuni][utilizator][tty]
```

### Exemple

sh
```
./last.sh -n 5
./last.sh -s 2025-01-01
./lastb.sh -t 2025-01-31 12:00:00
./lastb.sh -p 2025-09-10 12:00:00
./last.sh alice
./lastb.sh ana tty3
```


