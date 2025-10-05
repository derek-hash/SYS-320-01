<# String-Helper
*************************************************************
   This script contains functions that help with String/Match/Search
   operations. 
************************************************************* 
#>


<# ******************************************************
   Functions: Get Matching Lines
   Input:   1) Text with multiple lines  
            2) Keyword
   Output:  1) Array of lines that contain the keyword
********************************************************* #>
function getMatchingLines($contents, $lookline){

$allines = @()
$splitted =  $contents.split([Environment]::NewLine)

for($j=0; $j -lt $splitted.Count; $j++){  
 
   if($splitted[$j].Length -gt 0){  
        if($splitted[$j] -ilike $lookline){ $allines += $splitted[$j] }
   }

}

return $allines
}

<# ******************************************************
   Function: checkPassword
   Purpose: Validates password strength
   Input: Password string
   Output: True if password meets requirements, False otherwise
   
   Requirements:
   - At least 6 characters long
   - Contains at least 1 letter
   - Contains at least 1 number
   - Contains at least 1 special character
********************************************************* #>
function checkPassword($password){
   
   # Check if password is at least 6 characters
   if($password.Length -lt 6){
      return $false
   }
   
   # Check if password contains at least 1 letter
   if($password -notmatch '[a-zA-Z]'){
      return $false
   }
   
   # Check if password contains at least 1 number
   if($password -notmatch '\d'){
      return $false
   }
   
   # Check if password contains at least 1 special character
   if($password -notmatch '[^a-zA-Z0-9]'){
      return $false
   }
   
   # All conditions met
   return $true
}