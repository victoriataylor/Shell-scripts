#!/bin/bash
#
# Script name: spy.sh
#
# Description: takes two bdays and determines whether they occurred on the same day of the week
#
# Input: two dates in form of MM/DD/YYYY
#
# Output: tells the user which day of the week both dates fall on, and whether the two people
# were born on the same day of the week
#
# Pseudocode: the script first checks that there are two arguments and that they are both in correct date format.
# Then retrieves the day of the week of each date, prints each to console, and checks whether they are
# the same or not. 

#Exit if there aren't two args
if [ $# != 2 ]; then
	echo Incorrect num of args: must have 2 1>&2
	exit 1
#Exit if incorrect format of args
elif ! [[ `date -d "$1"` && `date -d "$2"` ]]; then 
	echo Please input both dates in form MM/DD/YYYY. 1>&2
	exit 1
else
	day1=`date -d "$1" "+%a"`
	day3=`date -d "$2" "+%a"`

	echo The first person was born on: $day1
	echo The second person was born on: $day3

	if [ "$day1" != "$day3" ]; then
		echo Therefore, you are not born on the same day of the week.
	else
		echo Jackpot! You were both born on the same day of the week!
	fi
fi
