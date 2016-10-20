<#
    .SYNOPSIS
    This script performs the installation or uninstallation of an application(s).
    .DESCRIPTION
    The script is provided as a template to perform an install or uninstall of an application(s).
    The script either performs an "Install" deployment type or an "Uninstall" deployment type.
    The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
    The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
    .PARAMETER DeploymentType
    The type of deployment to perform. Default is: Install.
    .PARAMETER DeployMode
    Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
    .PARAMETER AllowRebootPassThru
    Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
    .PARAMETER TerminalServerMode
    Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
    .PARAMETER DisableLogging
    Disables logging to file for the script. Default is: $false.
    .EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
    .EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
    .EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
    .EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
    .NOTES
    Toolkit Exit Code Ranges:
    60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
    69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
    70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
    .LINK 
    http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory=$false)]
  [ValidateSet('Install','Uninstall')]
  [string]$DeploymentType = 'Install',
  [Parameter(Mandatory=$false)]
  [ValidateSet('Interactive','Silent','NonInteractive')]
  [string]$DeployMode = 'Interactive',
  [Parameter(Mandatory=$false)]
  [switch]$AllowRebootPassThru = $false,
  [Parameter(Mandatory=$false)]
  [switch]$TerminalServerMode = $false,
  [Parameter(Mandatory=$false)]
  [switch]$DisableLogging = $false
)

Try {
  ## Set the script execution policy for this process
  Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
  ##*===============================================
  ##* VARIABLE DECLARATION
  ##*===============================================
  ## Variables: Application
  [string]$appVendor = 'Microsoft'
  [string]$appName = 'Office Scrubbers'
  [string]$appVersion = 'Various'
  [string]$appArch = 'x86'
  [string]$appLang = 'EN-us'
  [string]$appRevision = '01'
  [string]$appScriptVersion = '1.0.0'
  [string]$appScriptDate = '08/29/2016'
  [string]$appScriptAuthor = 'Jonathan Weinberg'
  ##*===============================================
  ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
  [string]$installName = ''
  [string]$installTitle = ''
	
  ##* Do not modify section below
  #region DoNotModify
	
  ## Variables: Exit Code
  [int32]$mainExitCode = 0
	
  ## Variables: Script
  [string]$deployAppScriptFriendlyName = 'Deploy Application'
  [version]$deployAppScriptVersion = [version]'3.6.8'
  [string]$deployAppScriptDate = '02/06/2016'
  [hashtable]$deployAppScriptParameters = $psBoundParameters
	
  ## Variables: Environment
  If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
  [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
  ## Dot source the required App Deploy Toolkit Functions
  Try {
    [string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
    If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
    If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
  }
  Catch {
    If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
    Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
    ## Exit the script, returning the exit code to SCCM
    If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
  }
	
  #endregion
  ##* Do not modify section above
  ##*===============================================
  ##* END VARIABLE DECLARATION
  ##*===============================================
		
  If ($deploymentType -ine 'Uninstall') {
    ##*===============================================
    ##* PRE-INSTALLATION
    ##*===============================================
    [string]$installPhase = 'Pre-Installation'
		
    ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
    Show-InstallationWelcome -CloseApps 'excel,groove,infopath,onenote,outlook,mspub,powerpnt,winword,winproj,visio,lync' -AllowDefer -DeferTimes 3 -PersistPrompt -BlockExecution
		
    ## Show Progress Message (with the default message)
    Show-InstallationProgress
		
    ## <Perform Pre-Installation tasks here>
    
    ##*===============================================
    ##* INSTALLATION 
    ##*===============================================
    [string]$installPhase = 'Installation'
		
    ## Handle Zero-Config MSI Installations
    If ($useDefaultMsi) {
      [hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
      Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
    }
		
    ## <Perform Installation tasks here>
    #$useDefaultMsi

    Show-InstallationProgress -StatusMessage 'BLAH BLAH BLAH THING 1'
    Remove-MSIApplications -Name "BLAH BLAH BLAH THING 1" -WildCard $true -ContinueOnError $true
    
    Show-InstallationProgress -StatusMessage 'BLAH BLAH BLAH THING 1'
    Remove-MSIApplications -Name "BLAH BLAH BLAH THING 2" -WildCard $true -ContinueOnError $true

    Show-InstallationProgress -StatusMessage 'Removing all Office 2003 related components. Stage 1 of 6 of scrubbing.'
    Execute-Process -Path "$dirfiles\CScriptNative.cmd" -Parameters "/B /NoLogo $dirFiles\2003\OffScrub03.vbs ALL /Quiet /NoCancel /Force /OSE" -WindowStyle Hidden -IgnoreExitCodes '1,2,3'
    
    Show-InstallationProgress -StatusMessage 'Removing all Office 2007 related components. Stage 2 of 6 of scrubbing.'
    Execute-Process -Path "$dirfiles\CScriptNative.cmd" -Parameters "/B /NoLogo $dirFiles\2007\OffScrub07.vbs ALL /Quiet /NoCancel /Force /OSE" -WindowStyle Hidden -IgnoreExitCodes '1,2,3'
    
    Show-InstallationProgress -StatusMessage 'Removing all Office 2010 related components. Stage 3 of 6 of scrubbing.'
    Execute-Process -Path "$dirfiles\CScriptNative.cmd" -Parameters "/B /NoLogo $dirFiles\2010\OffScrub10.vbs ALL /Quiet /NoCancel /Force /OSE" -WindowStyle Hidden -IgnoreExitCodes '1,2,3'
    
    Show-InstallationProgress -StatusMessage 'Removing all Office 2013 related components. Stage 4 of 6 of scrubbing.'
    Execute-Process -Path "$dirfiles\CScriptNative.cmd" -Parameters "/B /NoLogo $dirFiles\2013\OffScrub_O15msi.vbs ALL /Quiet /NoCancel /Force /OSE" -WindowStyle Hidden -IgnoreExitCodes '1,2,3'
    
    Show-InstallationProgress -StatusMessage 'Removing all Office 2016 related components. Stage 5 of 6 of scrubbing.'
    Execute-Process -Path "$dirfiles\CScriptNative.cmd" -Parameters "/B /NoLogo $dirFiles\2016\OffScrub_O16msi.vbs ALL /Quiet /NoCancel /Force /OSE" -WindowStyle Hidden -IgnoreExitCodes '1,2,3'
    
    Show-InstallationProgress -StatusMessage 'Removing all Office Click2Run related components. Stage 6 of 6 of scrubbing.'
    Execute-Process -Path "$dirfiles\CScriptNative.cmd" -Parameters "/B /NoLogo $dirFiles\C2R\OffScrubc2r.vbs ALL /Quiet /NoCancel /OSE" -WindowStyle Hidden -IgnoreExitCodes '1,2,3,42'
    
#    Show-InstallationProgress -StatusMessage 'Removing Outlook AddOn'    
#    Execute-ProcessAsUser -Path "$dirfiles\CScriptNative.cmd" -Parameters "$dirFiles\PluginRemoval\RemoveOutlookAddIns.vbs" -RunLevel HighestAvailable -Wait $true
    
#    Show-InstallationProgress -StatusMessage 'Removing Outlook Mail Profiles'    
#    Execute-ProcessAsUser -Path "$dirfiles\CScriptNative.cmd" -Parameters "$dirFiles\MailProfile\RemoveMailProfiles.vbs" -RunLevel HighestAvailable -Wait $true
    
    Show-InstallationProgress -StatusMessage 'Rename local appdata Outlook subfolder if existing.'
    $OutlookAppData = "$env:LOCALAPPDATA\Microsoft\Outlook"
    if ((Test-Path $OutlookAppData) -eq $True)
     {
      Rename-Item -Path $OutlookAppData -NewName "Outlook.Old" -Force -ErrorAction Continue
     }
     else
     {
     }
     
     New-Item -Path C:\Windows\Temp -Name OffScrubRun.ini -ItemType File
     
				
    ##*===============================================
    ##* POST-INSTALLATION
    ##*===============================================
    [string]$installPhase = 'Post-Installation'
		
    ## <Perform Post-Installation tasks here>

		
    ## Display a message at the end of the install
    If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'All set! Microsoft Office Programs Scrubbed. OffScrubRun.ini created in c:\windows\temp for recognition. Installation log files can be found here: "C:\Windows\Logs\Software", the scrubbing script logs are in %temp%.' -ButtonRightText 'OK' -Icon Information -NoWait }
  }
  ElseIf ($deploymentType -ieq 'Uninstall')
  {
    ##*===============================================
    ##* PRE-UNINSTALLATION
    ##*===============================================
    [string]$installPhase = 'Pre-Uninstallation'
		
    ## Show Welcome Message, close Chrome with a 60 second countdown before automatically closing
    Show-InstallationWelcome -CloseApps 'excel,groove,infopath,onenote,outlook,mspub,powerpnt,winword,winproj,visio,lync' -AllowDefer -DeferTimes 3 -PersistPrompt -BlockExecution
		
    ## Show Progress Message (with the default message)
    #Show-InstallationProgress
		
    ## <Perform Pre-Uninstallation tasks here>
		
		
    ##*===============================================
    ##* UNINSTALLATION
    ##*===============================================
    [string]$installPhase = 'Uninstallation'
		
    ## Handle Zero-Config MSI Uninstallations
    If ($useDefaultMsi) {
      [hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
      Execute-MSI @ExecuteDefaultMSISplat
    }
		
    # <Perform Uninstallation tasks here>

    Remove-Item -Path C:\Windows\Temp\OffScrubRun.ini
    

    ##*===============================================
    ##* POST-UNINSTALLATION
    ##*===============================================
    [string]$installPhase = 'Post-Uninstallation'
		
    ## <Perform Post-Uninstallation tasks here>
    Show-InstallationPrompt -Message 'All set! Microsoft Office Programs Scrub OffScrubRun.ini removed from c:\windows\temp. You can find a uninstallation logfile at the following location, "C:\Windows\Logs\Software", the scrubbing script logs are in %temp%.' -ButtonRightText 'OK' -Icon Information -NoWait
		
  }
	
  ##*===============================================
  ##* END SCRIPT BODY
  ##*===============================================
	
  ## Call the Exit-Script function to perform final cleanup operations
  Exit-Script -ExitCode $mainExitCode
}
Catch {
  [int32]$mainExitCode = 60001
  [string]$mainErrorMessage = "$(Resolve-Error)"
  Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
  Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
  Exit-Script -ExitCode $mainExitCode
}