#!/bin/bash

# Combine Apache logs
cat /var/log/apache2/access.log > access.txt 2>/dev/null
LOGS="access.txt"

# Display all logs
function allLogs(){
	cat "$LOGS"
}

# Display IPs with counts
function showIPs(){
    cat "$LOGS" | cut -d ' ' -f 1 | sort | uniq -c
}

# Display pages visited with counts
function showPages(){
	cat "$LOGS" | cut -d ' ' -f 7 | sort | uniq -c
}

# Create histogram of daily visits per IP
function dailyHistogram(){
	cat "$LOGS" | cut -d " " -f 1,4 | tr -d '[' | cut -d ":" -f 1 | sort | uniq -c
}

# Show IPs with more than 10 visits per day
function heavyVisitors(){
	dailyHistogram | awk '$1 > 10'
}

# Find suspicious visitors based on ioc.txt patterns
function suspiciousIPs(){
	cat "$LOGS" | grep -i -f ioc.txt | cut -d " " -f 1 | sort | uniq -c
}

# Main menu
while true
do
	echo "Please select an option:"
	echo "[1] Display all Logs"
	echo "[2] Display only IPs"
	echo "[3] Display only Pages"
	echo "[4] Histogram"
	echo "[5] Frequent Visitors"
	echo "[6] Suspicious Visitors"
	echo "[7] Quit"
	read choice
	echo ""
	
	case $choice in
		7) echo "Goodbye"; break;;
		1) echo "Displaying all logs:"; allLogs;;
		2) echo "Displaying only IPs:"; showIPs;;
		3) echo "Displaying only pages:"; showPages;;
		4) echo "Histogram:"; dailyHistogram;;
		5) echo "Frequent Visitors:"; heavyVisitors;;
		6) echo "Suspicious Visitors:"; suspiciousIPs;;
		*) echo "Invalid input try again";;
	esac
done
