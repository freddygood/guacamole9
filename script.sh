#!/bin/bash

function usage() {
	echo "Usage: $0"
	exit 0
}

unset -v GO_ARGS GO_TYPE GO_FILE
unset -v GO_LOG_FORMAT GO_TIME_FORMAT GO_DATE_FORMAT

while getopts ":t:f:A:h:z:n" opt; do
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
		'z')
			GUNZIP=true
			;;
		'n')
			ANONIMYZE=true
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
		if [ "$GUNZIP" ]; then
			gunzip -c $GO_FILE | goaccess --log-format=COMBINED $GO_ARGS -
		else
			cat $GO_FILE | goaccess --log-format=COMBINED $GO_ARGS -
		fi
		;;

	'php')
		if [ "$GUNZIP" ]; then
			if [ "$ANONIMYZE" ]; then
				gunzip -c $GO_FILE | sed -E \
					-e 's/(child|pid|trace|trace\ of) [0-9]{1,5}/\1 xxxxx/g' \
					-e 's/slow \([0-9\.]* sec\)/slow (x.xxx sec)/g' \
					-e 's|^(\[.{20}\]) (.*)$|\1 127.0.0.1 {{\2}}|g' \
						| goaccess --log-format="[%d %t] %h {{%r}}" --date-format="%d-%b-%Y" --time-format="%H:%M:%S" -
			else
				gunzip -c $GO_FILE | sed -E 's|^(\[.{20}\]) (.*)$|\1 127.0.0.1 {{\2}}|g' \
					| goaccess --log-format="[%d %t] %h {{%r}}" --date-format="%d-%b-%Y" --time-format="%H:%M:%S" -
			fi
		else
			if [ "$ANONIMYZE" ]; then
				cat $GO_FILE | sed -E \
					-e 's/(child|pid|trace|trace\ of) [0-9]{1,5}/\1 xxxxx/g' \
					-e 's/slow \([0-9\.]* sec\)/slow (x.xxx sec)/g' \
					-e 's|^(\[.{20}\]) (.*)$|\1 127.0.0.1 {{\2}}|g' \
						| goaccess --log-format="[%d %t] %h {{%r}}" --date-format="%d-%b-%Y" --time-format="%H:%M:%S" -
			else
				cat $GO_FILE | sed -E 's|^(\[.{20}\]) (.*)$|\1 127.0.0.1 {{\2}}|g' \
					| goaccess --log-format="[%d %t] %h {{%r}}" --date-format="%d-%b-%Y" --time-format="%H:%M:%S" -
			fi
		fi
		;;

	'error')
		if [ "$GUNZIP" ]; then
			if [ "$ANONIMYZE" ]; then
				gunzip -c $GO_FILE | sed -E \
					-e 's/^(.*) (\[.*), client: (.*), server: (.*), request: "(.*)", upstream: "(.*)", host: "([a-z0-9\.-_]*)"(, referrer: "(.*)")?$/\1 \3 \4 \7 "\9" {{\2 \5}}/g' \
					-e 's/ [0-9]{1,5}#[0-9]: / xxxxx#x: /g' \
					-e 's/ \*[0-9]{1,9} / *xxxxx /g' \
						| goaccess --log-format="%d %t %h %v %^ \"%R\" {{%r}}" --date-format="%Y/%m/%d" --time-format="%H:%M:%S" -
			else
				gunzip -c $GO_FILE | sed -E \
					-e 's/^(.*) (\[.*), client: (.*), server: (.*), request: "(.*)", upstream: "(.*)", host: "([a-z0-9\.-_]*)"(, referrer: "(.*)")?$/\1 \3 \4 \7 "\9" {{\2 \5}}/g' \
						| goaccess --log-format="%d %t %h %v %^ \"%R\" {{%r}}" --date-format="%Y/%m/%d" --time-format="%H:%M:%S" -
			fi
		else
			if [ "$ANONIMYZE" ]; then
				cat $GO_FILE | sed -E \
					-e 's/^(.*) (\[.*), client: (.*), server: (.*), request: "(.*)", upstream: "(.*)", host: "([a-z0-9\.-_]*)"(, referrer: "(.*)")?$/\1 \3 \4 \7 "\9" {{\2 \5}}/g' \
					-e 's/ [0-9]{1,5}#[0-9]: / xxxxx#x: /g' \
					-e 's/ \*[0-9]{1,9} / *xxxxx /g' \
						| goaccess --log-format="%d %t %h %v %^ \"%R\" {{%r}}" --date-format="%Y/%m/%d" --time-format="%H:%M:%S" -
			else
				cat $GO_FILE | sed -E \
					-e 's/^(.*) (\[.*), client: (.*), server: (.*), request: "(.*)", upstream: "(.*)", host: "([a-z0-9\.-_]*)"(, referrer: "(.*)")?$/\1 \3 \4 \7 "\9" {{\2 \5}}/g' \
						| goaccess --log-format="%d %t %h %v %^ \"%R\" {{%r}}" --date-format="%Y/%m/%d" --time-format="%H:%M:%S" -
			fi
		fi
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

