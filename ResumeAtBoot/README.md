  Resume at Boot by Schmurtz
=========================

Resume at Boot allows to totally power off your device without loosing your current game state.




## Features :
- Power off the device with a long press (3s) on Power button. It will triggers a save state just before the shutdown.
- The game will automatically resume at the next boot.
- display a shutdown image at power off (SD CARD/Themes/*Current_Theme*/skin/shutdown.png)
- play a sound at poweroff
- avoid to resume last game by pressing Menu button during the boot process.

## Details :


How to install :
===================================================================

"Auto load state" and "Auto save state" must be enabled in retroarch first.

[Download](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fschmurtzm%2FTrimUI-Smart-Pro%2Ftree%2Fmain%2FResumeAtBoot)

Copy System and trimui folders to the root of your SD card, then press power button 3 seconds during a game.
Press Menu button in continue during boot to cancel the automatic resume (useful if your game has crashed).



Additional information :
===================================================================
Resume at boot will start by replacing "/usr/trimui/bin/kill_apps.sh" script.
This script is launched by TrimUI keymon daemon when you press Power button 3s.
The new script will :

- Triggers a short vibration
- Show led blinking 
- Backup the current game command line (cmd_to_run.sh) 
- Triggers a save state and exit retroarch
- Display the shutdown background contained in "SD CARD/Themes/*Current_Theme*/skin/shutdown.png"
- Play a power off sound (/mnt/SDCARD/trimui/res/sound/PowerOff.wav)
- Shuwdown

Then at the next boot, trimui/app/preload.sh script is launched 
This script will:
- Exit without resuming the last game if Menu button is pressed in continue during the boot until the LEDs red flashes (see button_state.sh)
- Process to all the initialization of the device (sound, screen, controls, wifi...)
- Then launch the previously backuped cmd_to_run.sh


Special thanks :
================
Kloptops for sdl2imgshow and the new busybox :

https://github.com/kloptops/sdl2imgshow


