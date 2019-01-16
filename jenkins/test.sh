#!/bin/bash
 

getExeDate()
{
        if [ -z "$TIME" ]
        then
            TIME=`date "+%H:%M%S"`
        fi
}

getExeDate
echo $TIME
sleep 2
getExeDate
echo $TIME

 