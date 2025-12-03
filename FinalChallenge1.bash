html_content=$(curl -s http://10.0.17.47/IOC.html)
ioc_data=$(echo "$html_content" | grep -oP '(?<=<td>).*?(?=</td>)' | sed -n '1~2p')
echo "$ioc_data" > IOC.txt
