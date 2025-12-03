apacheLog=$1
indicatorFile=$2
cat "$apacheLog" | grep -i -f "$indicatorFile" | cut -d' ' -f1,4,7 | tr -d '[' > report.txt
