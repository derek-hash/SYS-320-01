# Import the Apache-Logs.ps1 script using dot notation
. "C:\Users\champuser\Desktop\SYS-320\Apache-Logs.ps1"

# Call the function with example parameters
# Adjust these parameters based on what's actually in your logs
$ipAddresses = Get-ApacheLogs -Page "404" -HTTPCode "404" -Browser "Mozilla"

# Display the IP addresses
Write-Host "IP Addresses found:"
$ipAddresses

# Count the IP addresses
Write-Host "Total IP Count: $($ipAddresses.Count)"
