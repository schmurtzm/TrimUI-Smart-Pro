  System Tools by Schmurtz
=========================

System Tools : is a kind of container for all the system apps created by the community.
It allows to have only one entry point, ordered by category to help the users to find the app or the script he needs. I have created it to organize Tomato's OS apps by sections and I've added some new tools.

<a href="./_assets/System Tools.png">
    <img src="./_assets/System Tools.png" alt="System Tools" width="320">
</a>

## Features :
- Multiple level menu (easy to modify)
- Supports pictures with feature description

## Details :

### EMULATORS
 - PSX Analog Detector : Detect PSX games compatible with analog sticks and automatically set the right controller configuration
 - AUTO LOAD STATE : Load the last save state automatically when launching game

### LEDS    
These options will set behavior, this is persistant (restored after each boot).
 - Default : default LED behavior from stock ()
 - Battery level : ```>0%: red, >20%: Vermilion, >30%: Red Orange, >40%: Dark Orange, >50%: Orange, >60%: Yellow, >80%: Chartreuse Green, >90%: Green```
 - CPU Speed : ```<1200MHz: Green, 1201-1300MHz: Chartreuse Green, 1301-1900MHz: Dark Orange, 1901-1991MHz: Vermilion, >1991MHz: Red```
 - Rainbow : change leds colors all the time 
 - Temperature : ```<=40°C: Green, 41-45°C: Chartreuse Green, 46-50°C: Yellow, 51-55°C: Orange, 56-60°C: Dark Orange, 61-65°C: Red Orange, 66-70°C: Vermilion, >70°C: Red```
	

### NETWORK	
 - Display IP.sh : Display current IP
 - SFTPGo : Disable / Enable SFTPGo (require PortMaster installed)
 - SSH : Disable / Enable SSH (require PortMaster installed)
### THEME
 - SOUND
	 - CLICK : Disable / Enable "click" sound for the current theme
	 - MUSIC : Disable / Enable music sound for the current theme
 - TOP LEFT LOGO : Disable / Enable top left for the current theme
### TOOLS
 - CPU - Max.sh : force CPU to max speed (until the next reboot)
 - UDISK - Format.sh : for experimented users only: allows to format UDsik partition and have access to 6GB of internal storage.
### USER INTERFACE
 - START TAB : choose your starting tab (know issue: can shift depending the number of tabs displayed)



How to install :
===================================================================
Copy Apps, Emus and System folders to the root of your SD card, then run the app "System Tools".



Additional information :
===================================================================
System Tools : is a kind of container for all the system apps created by the community.
It allows to have only one entry point, ordered by category to help the users to find the app or the script he needs. I have initially created it to organize Tomato's OS apps by sections and I've added some stuffs.

System Tools doesn't require any build environnement to be edited : it's only a collections of tricks based on MainUI from the official firmware.  So all is basic but the advantage is that all is easy to understanf and modify for your own use.

PSX Analog Detector is working like that : 
adding the current PSX games to the RetroArch database
comparing the entries from RetroArch database to a database of games compatibles with analog sticks / dual shock
For each compatible entry, creating a dedicated remap config file for this game (we will create 3 remap config items : for PCSX Rearmed, DuckStation and SwanStation cores)

AUTO LOAD STATE: 
Will just modify the current RetroArch configuration to determin if we load or not the last save state (to be used with automatic save state at exit);



Special thanks :
================
Kloptops for sdl2imgshow and the new busybox :

https://github.com/kloptops/sdl2imgshow

Djware for multiple scripts :

https://github.com/djware/TrimUITools
