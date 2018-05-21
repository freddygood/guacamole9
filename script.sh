#!/bin/bash

function usage() {
	echo "Usage: $0"
	exit 0
}

unset -v GO_ARGS GO_TYPE GO_FILE
unset -v GO_LOG_FORMAT GO_TIME_FORMAT GO_DATE_FORMAT

while getopts ":t:f:A:h" opt; do
	case $opt in
		't')
			GO_TYPE=$OPTARG
			;;
		'f')
			GO_FILE=$OPTARG
			;;
		'A')
			GO_ARGS=$OPTARG
			;;
		'h')
			usage
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			usage
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			usage
			;;
	esac
done

case $GO_TYPE in
	'apache')
		echo "Run command: goaccess --log-format=COMBINED $GO_FILE"
		goaccess --log-format=COMBINED $GO_FILE
		;;
	'php')
		echo "Sed command: sed -E 's|^(\[.{20}\]) (.*)$|\1 127.0.0.1 {{\2}}|g' $GO_FILE"
		echo "Goaccess command: goaccess --log-format=\"[%d %t] %h {{%r}}\" --date-format=\"%d-%b-%Y\" --time-format=\"%H:%M:%S\" -"
		sed -E 's|^(\[.{20}\]) (.*)$|\1 127.0.0.1 {{\2}}|g' $GO_FILE | goaccess --log-format="[%d %t] %h {{%r}}" --date-format="%d-%b-%Y" --time-format="%H:%M:%S" -
		;;
	'psql'|'postgres')
		GO_LOG_FORMAT=''
		GO_DATE_FORMAT='%Y-%b-%d'
		GO_TIME_FORMAT='%H:%M:%S'
		;;
	*)
		usage
		;;
esac

