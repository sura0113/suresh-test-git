<#
*** THIS SCRIPT IS PROVIDED WITHOUT WARRANTY, USE AT YOUR OWN RISK ***
.DESCRIPTION
    Use the win32_LogicalDisk WMI Class to get Local Disk Information for one
    or multiple computers. 
    Information gathered: 
        System Name    DeviceID   Volume Name  Size(GB)   FreeSpace(GB)  % FreeSpace(GB)   Date

    Output options include Out-Gridview, a Table, CSV file and an HTML file.

.NOTES
	File Name: 
	Author: David Hall
	Contact Info: 
		Website: www.signalwarrant.com
		Twitter: @signalwarrant
		Facebook: facebook.com/signalwarrant/
		Google +: plus.google.com/113307879414407675617
		YouTube Subscribe link: https://www.youtube.com/c/SignalWarrant1?sub_confirmation=1
	Requires:  
	Tested: Windows 10 (PS v5), Windows Server 2012R2 (PS v4)

.PARAMETER None
 
.EXAMPLE 

.INFORMATION
    For a list of Drive Types for the Win32_LogicalDisk class visit the link below
    https://technet.microsoft.com/en-us/library/ee176674.aspx
#>

#$serverlist=get-content .\servers.txt  
$serverlist=get-content C:\git\suresh-test-git\servers.txt
write-output "Server,RAM,Pagefile" 
 
foreach ($server in $serverlist) { 
 
 $physicalmem=get-wmiobject -computer $server Win32_ComputerSystem | % {$_.TotalPhysicalMemory} 
 $Physicalmem=[math]::round($physicalmem/1MB,0) 
 $Pagefilesize=get-wmiobject -computer $server Win32_pagefileusage | % {$_.AllocatedBaseSize} 
 Write-Output "$server,$physicalmem,$pagefilesize" 
 
}

$exportPath = "C:\git\suresh-test-git\" # I change this to a central fileshare

# Your computers.txt will need to be in this folder.
#$computers = Get-Content "C:\scripts\drive_info\computers.txt"

$driveinfo = Get-WMIobject win32_LogicalDisk -ComputerName . -filter "DriveType=3" |
                Select-Object SystemName, DeviceID, VolumeName,
                @{Name="Size(GB)"; Expression={"{0:N1}" -f($_.size/1gb)}},
                @{Name="FreeSpace(GB)"; Expression={"{0:N1}" -f($_.freespace/1gb)}},
                @{Name="% FreeSpace(GB)"; Expression={"{0:N2}%" -f(($_.freespace/$_.size)*100)}},
                @{Name="Date"; Expression={$(Get-Date -format 'g')}} 

# Various Output Options
#$driveinfo | Out-GridView 
$driveinfo | Format-Table -AutoSize
 $physicalmem=get-wmiobject -computer . Win32_ComputerSystem | % {$_.TotalPhysicalMemory} 
 $Physicalmem=[math]::round($physicalmem/1MB,0)
 $Pagefilesize=get-wmiobject -computer . Win32_pagefileusage | % {$_.AllocatedBaseSize} 
#$driveinfo | Export-Csv "$exportPath\diskinfo.csv" -NoTypeInformation -NoClobber -Append