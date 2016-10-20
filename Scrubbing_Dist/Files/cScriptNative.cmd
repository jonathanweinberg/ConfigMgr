@echo off
rem CScriptNative.cmd
rem Author: Jay Michaud (www.deploymentmadscientist.com)
rem Date: 2016-03-02
rem Source: http://www.deploymentmadscientist.com/2016/02/08/deploying-microsoft-office-2016-removing-old-versions/
rem Acknowledgement: Inspired by Andrew Lukaszewski's blog at https://madluka.wordpress.com/2012/09/24/configmgr-2012-64bit-file-system-redirection-bites-again/
rem Description: Use this command script in place of cscript.exe to ensure that the script runs as a 64-bit process on 64-bit operating systems.
rem This is useful when deploying a script as a package program in Microsoft System Center Configuration Manager, where the engine that runs the package program is a 32-bit process on 64-bit Windows.
rem Example: Instead of
rem cscript.exe //B //NoLogo "\\server\share\path\to\my script.vbs"
rem run
rem NativeCScript //B //NoLogo "\\server\share\path\to\my script.vbs"

rem On 32-bit Windows, the PROCESSOR_ARCHITEW6432 environment variable is not defined by the operating system.
rem On 64-bit Windows, the PROCESSOR_ARCHITEW6432 environment variable is not defined by the operating system in 64-bit processes.
rem On 64-bit Windows, the PROCESSOR_ARCHITEW6432 environment variable is defined by the operating system in 32-bit processes as "AMD64" (without quotation marks).

if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
rem Currently running as 32-bit process on 64-bit Windows (SysWOW64)
rem Launch CScript through Sysnative
"%SystemRoot%\Sysnative\cscript.exe" %*
) else (
"%SystemRoot%\System32\cscript.exe" %*
)