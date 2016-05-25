# Shell-scripts
This repo contains two shell scripts written in bash.

###url_search.sh 
Gives the number of times keywords appear on each webpage listed in a file. It takes as input a file containing a list of urls
as well as any number of keywords, and outputs each webpage, followed by the number of times each keyword appears on it. </br>
``url_search.sh url.txt keyword1``

###spy.sh
Description: Monitors when users log in and out of a machine. Once killed, it creates a summary of how many times each user logged
on and off. It also computes which user was logged in the most total time, and who had the longest and shortest sessions. Takes as input
a list of users to monitor. </br>
Usage: </br>
``spy.sh user1 user2 user3``
