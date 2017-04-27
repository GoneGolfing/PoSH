Function Get-Report
{

Import-CSV C:\Report.csv  |

ForEach-Object {

  $data = Get-ADUser $_.Name -Properties Department | select department

  $_ | Add-Member -MemberType NoteProperty -Name Department -Value $data.department -PassThru 


} |
Export-CSV -Path C:\Temp\Report.csv 
}