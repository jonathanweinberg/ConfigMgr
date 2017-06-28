# Why use this

The current variant of #Petya \ #NotPetya, has a check for the existence of this file "c:\Windows\perfc"

Presence of the file stops the malware dead.

There are finding that the file could have to be named on of these variations:

* perfc
* perfc.dll
* perfc.dat
* perfc.bat

## What does this Configuration Item / Configuration Baseline Pack do

If "killswitch" files for #NotPetya do not exist, it remediates by creating them with a ReadOnly $True attribute.

If "killswitch" files exist, it checks for the ReadOnly attribute being $True. If $False, it remediates to $True.

The file "NotPetya_KillSwitchFiles_SCCM_DCM.cab" is importable directly into ConfigMgr (Tested in 1702 CB).

Download here: [https://github.com/jonathanweinberg/ConfigMgr/tree/master/DCM/NotPetya_KillSwitch/NotPetya_KillSwitchFiles_SCCM_DCM.cab](https://github.com/jonathanweinberg/ConfigMgr/tree/master/DCM/NotPetya_KillSwitch/NotPetya_KillSwitchFiles_SCCM_DCM.cab)

Extract the above CAB and you can view the XML to see structure before import.

## Alternatives

Fastest action will be deploying via GPO / GPP creation of these files (Use GPP to copy something like win.ini to perfc.dat w/ReadOnly Flag). This can then be followed by using the DCM to ensure that the files have been created.

Later you can remove these files with the same methods.

### PowerShell

These are the commands used in PowerShell to create, verify, and set requirements.

``` powershell


#Test For Existence of Killswitch Files
Test-Path -Path 'c:\Windows\perfc'
Test-Path -Path 'c:\Windows\perfc.dll'
Test-Path -Path 'c:\Windows\perfc.dat'
Test-Path -Path 'c:\Windows\perfc.bat'

#Create KillSwitche Files
New-Item -ItemType File -Path 'C:\Windows\' -Name 'perfc' -Verbose -Force -ErrorAction Continue | Set-ItemProperty -Name IsReadOnly -Value $True
New-Item -ItemType File -Path 'C:\Windows\' -Name 'perfc.dll' -Verbose -Force -ErrorAction Continue | Set-ItemProperty -Name IsReadOnly -Value $True
New-Item -ItemType File -Path 'C:\Windows\' -Name 'perfc.dat' -Verbose -Force -ErrorAction Continue | Set-ItemProperty -Name IsReadOnly -Value $True
New-Item -ItemType File -Path 'C:\Windows\' -Name 'perfc.bat' -Verbose -Force -ErrorAction Continue | Set-ItemProperty -Name IsReadOnly -Value $True

#Test Files are ReadOnly
(Get-Item 'c:\Windows\perfc').IsReadOnly
(Get-Item 'c:\Windows\perfc.dll').IsReadOnly
(Get-Item 'c:\Windows\perfc.dat').IsReadOnly
(Get-Item 'c:\Windows\perfc.bat').IsReadOnly

#Remediate ReadOnly setting
Set-ItemProperty -Path 'c:\Windows\perfc' -Name IsReadOnly -Value $True -PassThru
Set-ItemProperty -Path 'c:\Windows\perfc.dll' -Name IsReadOnly -Value $True -PassThru
Set-ItemProperty -Path 'c:\Windows\perfc.dat' -Name IsReadOnly -Value $True -PassThru
Set-ItemProperty -Path 'c:\Windows\perfc.bat' -Name IsReadOnly -Value $True -PassThru

```