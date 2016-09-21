<#
 email notification for when ad sync fails 
 
 
 9/2/2016

 AlertTriggerEmail.ps1

 v1.0 - create initial script
 v1.1 - add restart of ad sync service if running and start adsync service if stopped

#>

#import ad sync powershell module
Import-Module ADSync



#variable that retrieves last successful time for ad connect sync
$syncTrigger = Get-EventLog -LogName Application -Source 'Directory Synchronization' -Message 'Import/Sync/Export cycle completed (Delta).' -ComputerName server1 -Newest 1  | Select-Object timegenerated

#convert system formatted date string to just hours and minutes
$dateConversion = $syncTrigger.TimeGenerated.ToShortTimeString() 

#restart ad sync service if it is hung. start service if status is stopped

$adSyncService = Get-Service -Name ADSync 

if ($adSyncService.Status -eq 'Running')
{
   Restart-Service -Name ADSync -Force 
}

if ($adSyncService.Status -eq 'Stopped')
{
    Start-Service -Name ADSync 
}

#check logs for successfull restart of service and converts system formatted date string to just hours and minutes

$checkServiceRestart = Get-EventLog -LogName Application -Source 'ADSync' -Message 'The service was started successfully.' -ComputerName server1 -Newest 1 | Select-Object timegenerated
$serviceRestartTime = $checkServiceRestart.TimeGenerated.ToShortTimeString() 

Start-ADSyncSyncCycle -PolicyType delta 


#email notification
Send-MailMessage -SmtpServer relay.test.com -From admin@test.com -to monitoring@test.com -Subject "AD Connect Sync Failure" -BodyAsHtml "AD Sync has reported a synchronization failure. The  ADSync service was successfully restarted at $serviceRestartTime. The last successful sync was at $dateConversion."