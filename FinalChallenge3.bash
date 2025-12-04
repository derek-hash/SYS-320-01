inputReport="report.txt"
outputHTML="/var/www/html/report.html"
echo "<html><body><table border='1' cellspacing='5'>" > $outputHTML
while IFS= read -r entry
	do
		echo "<tr><td>$entry</td></tr>" >> $outputHTML
	done < "$inputReport"
echo "</table></body></html>" >> $outputHTML
