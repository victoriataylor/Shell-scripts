#!/bin/bash
#
# Script name: spy.sh
#
# Description: Monitors when users log in and out of a machine. Once killed, it creates a summary of how many times each user logged
# on and off. It also computes which user was logged in the most total time, and who had the longest and shortest sessions.
#
# Input: List of users to monitor in terms of their full names. 
#
# Pseudocode: The script translates the arg names into usernames using the etc/passwd file. While running, it is in an infinite while loop.
# The status of whether each user is offline/online is held in an array. Every 60 seconds it checks the current status of the user
# (whether or not they are currently logged in) and compares it to the stored status (in array). If current status and stored status are
# different, this signals a user has logged on or off, and the date/time is then appended to a file by that user's name. When the script
# is terminated, the trap function catches it and sends the output of the function finish to spy.log. Finish handles the header spy.log
# and then calls handleLog. handleLog loops through all the users and their text files. If the user has no corresponding text file, this
# means they never logged in. Otherwise it goes through the text files two lines at a time (login date and logout date) and calculates
# the time difference between them. After going through each file and storing the times in an array, it deletes the file. It then prints
# each users total sessions and session times, and all the times they logged in and out. handleLog also keeps track of shortest session, 
#longest session, and most time spent on the machine. The program exits after handleLogs completion.

starttime=`date`
args=$@

# Find corresponding usernames to args, if any
users=[]; i=0	#create array and variable to iterate through it
for name in "$@"; do
	username=$(grep "$name" /etc/passwd | awk -F: '{print $1}')	
	#If the name did not correspond to any users, print that, otherwise
	#add username to the array and increment i
	if [ -z "$username" ]; then
		echo $name does not correspond to any users
		exit 1
	else
		users[i]="$username"
		let i+=1
	fi
done

# Handles each user's text file and determines user superlatives
handleLog () {
	mostTime=0; mostTimeUser=""
	shortestSess=100000; shortestSessUser=""
	longestSess=0; longestSessUser=""
	
	# Loops through all users
        for  ((i=0;i<${#users[*]};i++)); do
		user="${users[$i]}"

		# If there is no text file for a user, they never logged into the machine.
		if ! [ -f "$user".txt ]; then
			echo -e "$user never logged in.\n"   
		else 
			linenum=1
			numsess=0 #number of sessions
			totalusertime=0
			logtimes=[]; arrayindex=0 #array to save all user's times

			# Parse user file
			while [ $linenum -le `cat "$user".txt | wc -l` ]; do
				#grab login and logout date/time from file and store it in an array
				login=`sed "$linenum"!d "$user".txt`; let linenum++
				logout=`sed "$linenum"!d "$user".txt`; let linenum++
				logtimes[$arrayindex]="$login"; let arrayindex++
				logtimes[$arrayindex]="$logout"; let arrayindex++

				#calculate length of each session and check to see if its the shortest or longest session
				sessiontime=$(((`date --date="$logout" +"%s"` - `date --date="$login" +"%s"`)/60))
				if [ "$sessiontime" -le "$shortestSess" ]; then
					shortestSess=$sessiontime
					shortestSessUser="$user"; fi
				if [ "$sessiontime" -ge "$longestSess" ]; then
					longestSess=$sessiontime
					longestSessUser="$user"; fi

				#update total user time and number of sessions
				let totalusertime=$((totalusertime+sessiontime))
				let numsess++
			done

			# When done using user file, remove it			
			rm "$user".txt

			#Check to see if user's total time is more than previous records
			if [ "$totalusertime" -ge "$mostTime" ]; then
				mostTime=$totalusertime
				mostTimeUser=$user; fi

			# Userlog breakdown
			echo "$user logged on $numsess times for a total period of $totalusertime minutes. Here is the breakdown:"
			z=0
			while [ "$z" -lt $((${#logtimes[*]}/2)) ]; do
				echo "$((z+1))) Logged on "${logtimes[$((z*2))]}"; logged off "${logtimes[$((z*2+1))]}""
				let z++
			done
			echo #to create newline between users
		fi 
	done
	# Print spy's superlatives
	echo $mostTimeUser spent the most time on wildcat today - $mostTime mins in total for all his/her sessions.
	echo $shortestSessUser was on for the shortest session for a period of $shortestSess mins, and is therefore the most sneaky.
	echo $longestSessUser was logged on for the longest session of $longestSess mins. 
}
 
# Executes upon killing spy- cleans up and creates spy.log
function finish {
	#if user is online when spy terminates, append the date to their file 
	for ((i=0;i<${#users[*]};i++)); do
		if [ `who | grep "${users[$i]}" | wc -l` -gt 0 ]; then
			date >> "${users[$i]}".txt
		fi
	done

	#header of spy.log
	echo spy.sh Report 
	echo "started at `date -d "$starttime" +"%H:%M"` on `date -d "$starttime" +"%m/%d/%y"`"
	echo "stopped at `date +"%H:%M"` on `date +"%m/%d/%y"`"
	echo -e "arguments: $args \n"
	handleLog
	exit
}
trap 'finish > spy.log' SIGUSR1


# Create an array to hold user status and initialize them all to offline
online=[]
for ((i=0;i<${#users[*]};i++)); do
        online[$i]="false"
done

# While spy is running, check to see if user's last status is the same as their current status
# if not, append date/time to their user file
while [ true ] ; do
	for  ((i=0;i<${#users[*]};i++)); do
		# If user is currently online and their status says they aren't, append the date/time 
		# to a file by their username and update their status
		if [ `who | grep "${users[$i]}" | wc -l` -gt 0 ]; then

			if [ "${online[$i]}" == "false" ]; then
				date >> "${users[$i]}".txt
				online[$i]="true"
			fi
		#If user is currently offline and their last updated status says they are online, append
		# the date/time to their file and update their status	
		elif [ `who | grep "${users[$i]}" | wc -l` -eq 0 ]; then
			if [ "${online[$i]}" == "true" ]; then
				date >> "${users[$i]}".txt
				online[$i]="false"
			fi
		fi
	done
	sleep 60
done

