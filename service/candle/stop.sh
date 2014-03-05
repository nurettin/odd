#!/bin/bash
printf "Stopping\n"
if [ -f ./pid ]
then
  PID=`cat pid`
  printf "Killing process $PID\n"
  
  while true
  do

    kill $PID
    sleep 1
    kill -0 $PID 1> /dev/null 2> /dev/null
    if [ $? -eq  0 ]
    then
      echo "Trying to kill $PID again"
    else
      echo "Process $PID killed"
      rm pid
      exit 0
    fi

  done
else
  printf "Process id file not found\n"
  exit 1
fi

