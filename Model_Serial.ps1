<#
.FILENAME
Model_Serial.ps1

.VERSION
1.0

.SHORT DESCRIPTION
Names PC during SCCM OSD With ModelName-SerialNumber from WMI 

.LONG DESCRIPTION AND STEPS
Modification of the script created by Dan Padgett for naming a device with more than just a Serial number.

The basis for this was created by Dan Padgett and is visible here:
http://apppackagetips.blogspot.com/2016/04/sccm-osd-name-pc-simple-powershell.html
https://gist.github.com/padgo/54f0f7690416a38e30da6ab40d6cd87d#file-ztiname-ps1

Steps
1. Collect entire serial number from WMI. The changing of the variable to $SerialNo from $Serial is somewhat redundant, but this is to allow the use of substring if needed like we will do for the friendly model name. 
2. $ModelName is created by using substring to select the last 4 characters of the friendly model name. This might need to change to a RegEx depending on how the name is formatted should things change for Lenovo devices.
3. Create a Task Sequence Variable.

.REQUIREMENTS \ TESTED WITH
Microsoft ConfigMgr 2012 CB 1606 USB Media OSD
Windows 10 1607

.FUTURE
Error Logging Output
Transformed into a function of toggling of functionality (location codes, model specific actions)

.AUTHOR
Jonathan Weinberg

.DATE
11/18/2016
#>

<#	
	.NOTES
	===========================================================================
	 Created on:   	17/11/2016
	 Created by:   	JWeinberg
	 Filename:     Model_Serial.ps1

	===========================================================================
	.DESCRIPTION
		Names PC during SCCM OSD With ModelName-SerialNumber from WMI 
#>

$Serial = Get-WmiObject -Query 'select IdentifyingNumber from Win32_ComputerSystemProduct' -Namespace 'Root\cimv2'
$Model = Get-WmiObject -Query 'select Version from Win32_ComputerSystemProduct' -Namespace 'Root\cimv2'
$SerialNo = $Serial.IdentifyingNumber
$ModelName = $Model.Version | ForEach-Object {$_.SubString($_.length-4)}
$TS = New-Object -ComObject "Microsoft.SMS.TSEnvironment"
$TS.Value("OSDComputerName") = "$ModelName" + '-' + $SerialNo
$TS.Value("XModel") = $Model.Name
