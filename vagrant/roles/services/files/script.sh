#!/bin/bash

# This script load some data to Redis key

DATUM=`date`
LOG="/var/log/redis/script_load.log"

/usr/bin/redis-cli -h 127.0.0.1 set key "Hello/World - $DATUM"

        if [ $? -eq 0 ]; then
                echo -e "Uspjesan unos" >> $LOG
                echo -e "-----provjera-----" >> $LOG
                /usr/bin/redis-cli -h 127.0.0.1 get key >> $LOG
                echo -e "------------------" >> $LOG
        else
                echo -e "NIJE uspjesan unos" >> $LOG
                echo -e "------------------" >> $LOG
        fi
