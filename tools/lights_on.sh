#!/bin/bash

# Color tags
	RED='\e[0;31m'
	YEL='\e[1;33m'
	GRN='\e[1;32m'
	NC='\e[0m'

# Preliminary
	HOST=8.8.8.8
	PING_RESULT="1"
	GRN_LIGHT="${GRN}O${NC}"
	RED_LIGHT="${RED}X${NC}"
	SINGLE_TAB_SEP="\t|"
	DOUBLE_TAB_SEP="\t\t|"

table_header(){
	echo -e "\n\t--Targets--"\
	"$SINGLE_TAB_SEP"\
	"Status"\
	"$SINGLE_TAB_SEP"

	printf '\t%70s\n' | tr ' ' -
}

snort_service(){
	if ps ax | grep -v grep | grep snort > /dev/null; then
		echo -e "\tSnort Service"\
		"$SINGLE_TAB_SEP"\
		"$GRN_LIGHT"\
		"$DOUBLE_TAB_SEP"
	else
		echo -e "\tSnort Service"\
		"$SINGLE_TAB_SEP"\
		"$RED_LIGHT"\
		"$DOUBLE_TAB_SEP"\
		"Snort is not working. Do something."
	fi
}

ping_check(){
	if [ "$PING_RESULT" != `ping $HOST -c 1 | grep -E -o '[0-9]+ received' | cut -f1 -d' '` ]; then
		echo -e "\t8.8.8.8 alive"\
		"$SINGLE_TAB_SEP"\
		"$RED_LIGHT"\
		"$DOUBLE_TAB_SEP"\
		"The host is probably down."
	else
        	echo -e "\t8.8.8.8 alive"\
		"$SINGLE_TAB_SEP"\
		"$GRN_LIGHT"\
		"$DOUBLE_TAB_SEP"
        fi
}

table_tailer(){
	echo -e "\n\tTime interval betwen each round check is 10 seconds."
}

while true; do
	table_header
	snort_service
	ping_check
	table_tailer

	sleep 10
	clear
done

