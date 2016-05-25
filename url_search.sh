#!/bin/bash
# Script name: url_search.sh
#
# Description: Gives the number of times keywords appear on each webpage listed in a file. 
#
# Input: File containing a list of urls, and any number of keywords 
#
# Output: Gives each keyword, followed by a list of the number of times it appears on each webpage
#
# Pseudocode: The script loops through all of the urls in the file, making an html file in form 
# of #.html for each one. It saves the url as the first line in each html file. It then puts all
# of the file names in an array, so that we can loop through them later. Then for every keyword,
# it prints the keyword and loops through the html files counting occurences of the keyword and
# printing the url (grabbed from the first line of the html file) and keyword count. At the end
# it loops through the array and deletes all html files created.

#CHECKS BEFORE BEGIN
#check to make sure there are at least two args
if [ "$#" -lt "2" ]; then echo Must give file and at least one keyword; exit 1
#test whether first arg is file
elif ! [[ -f $1 ]]; then echo First arg must be file; exit 1
#test if file is empty
elif ! [[ -s $1 ]]; then echo File empty: no urls to search.; exit 1
#test read permissions of file
elif ! [[ -r $1 ]]; then echo File unreadable; exit 1; fi

#Create html files for each url in arg files
z=1
HTMLfiles=[]
while read line; do 
	echo $line > "$z".html	#make url first line of file for quick access
	curl -s $line>> "$z".html 
	HTMLfiles[z]="$z".html  #put filenames in array to easily access and remove them later
	let z+=1
done <$1

#for every keyword, scan each html files for occurences
for ((keyword=2;keyword<=$#;keyword++)); do
	printf "${!keyword} \n"
	#for file in *.html; do
	for ((i=1;i<${#HTMLfiles[*]};i++)); do
		wordCount=`grep -o "${!keyword}" ${HTMLfiles[$i]} | wc -w` 
		url=$(head -n 1 ${HTMLfiles[$i]})				#get url from file
		printf "$url $wordCount \n"			
	done
	printf "\n"
done

for ((i=1;i<${#HTMLfiles[*]};i++)); do
	rm ${HTMLfiles[$i]}
done

 	
