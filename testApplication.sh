#!/bin/sh
for count in 1 2 3 4 5 6
do
  result=$(/usr/bin/curl -s http://192.168.33.10)
  echo $result
done
