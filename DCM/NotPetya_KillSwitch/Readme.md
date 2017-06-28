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

Link to file: [https://github.com/jonathanweinberg/ConfigMgr/tree/master/DCM/NotPetya_KillSwitch](https://github.com/jonathanweinberg/ConfigMgr/tree/master/DCM/NotPetya_KillSwitch)
