# Dot source the first script to load its functions
. "C:\Users\champuser\Desktop\SYS-320\LoginLogout.ps1"

clear

# Get Login and Logoffs from the last 15 days
$loginoutsTable = Get-LoginLogoffEvents -Days 15
$loginoutsTable

# Get Shut Downs from the last 25 days
$shutdownsTable = Get-StartShutdownEvents -Days 25
$shutdownsTable

# Get Start Ups from the last 25 days
$startupsTable = Get-StartShutdownEvents -Days 25
$startupsTable