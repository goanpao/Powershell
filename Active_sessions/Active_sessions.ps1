$LogFile = "C:\scripts\Active_sessions\ActiveSessions_" + $([DateTime]::Now.ToString('yyyyMMdd')) + ".log"
$ComputerName = Get-Content "C:\Scripts\Active_sessions\sysservers.txt"
foreach ($Computer in $ComputerName)
{
function Write-Log([string]$message)
{
   Out-File -InputObject $message -FilePath $LogFile -Append
}
function Get-Sessions
{
   #$queryResults = query session
   $queryResults = qwinsta /server:$Computer
   $starters = New-Object psobject -Property @{"SessionName" = 0; "UserName" = 0; "ID" = 0; "State" = 0; "Type" = 0; "Device" = 0;}
   foreach ($result in $queryResults)
   {
      try
      {
         if($result.trim().substring(0, $result.trim().indexof(" ")) -eq "SESSIONNAME")
         {
            $starters.UserName = $result.indexof("USERNAME");
            $starters.ID = $result.indexof("ID");
            $starters.State = $result.indexof("STATE");
            $starters.Type = $result.indexof("TYPE");
            $starters.Device = $result.indexof("DEVICE");
            continue;
         }
 
         New-Object psobject -Property @{
            "SessionName" = $result.trim().substring(0, $result.trim().indexof(" ")).trim(">");
            "Username" = $result.Substring($starters.Username, $result.IndexOf(" ", $starters.Username) - $starters.Username);
            "ID" = $result.Substring($result.IndexOf(" ", $starters.Username), $starters.ID - $result.IndexOf(" ", $starters.Username) + 2).trim();
            "State" = $result.Substring($starters.State, $result.IndexOf(" ", $starters.State)-$starters.State).trim();
            "Type" = $result.Substring($starters.Type, $starters.Device - $starters.Type).trim();
            "Device" = $result.Substring($starters.Device).trim()
         }
      } 
      catch 
      {
         $e = $_;
         Write-Log "ERROR: " + $e.PSMessageDetails
      }
   }
}
 
[string]$IncludeStates = '^(Active)$'
Write-Log -Message " "
Write-Log -Message " "
Write-Log -Message "Active sessions on : $Computer"
$ActiveSessions = Get-Sessions | ? {$_.State -match $IncludeStates -and $_.UserName -ne ""} | Select ID,UserName
Write-Log -Message "============================="
foreach ($session in $ActiveSessions)
{
   Write-Log -Message $session.Username   
}
Write-Log -Message "Finished"
Write-Log -Message "------------------------------"
Write-Log -Message " "
}