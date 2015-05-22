#!/bin/bash

open(){
	for port in {1..10};
	do
		netcat -l $port &
	done
}

case $1 in
	"open")
		open
		echo "Doors opened QQ"
	;;
	"close")
		netcat -z -v -n $2 1-10
		echo "Closed $2 's door"
	;;
	*)
		echo "Usage: bash $0 open"
		echo "Usage: bash $0 close ipaddr"
	;;
esac
