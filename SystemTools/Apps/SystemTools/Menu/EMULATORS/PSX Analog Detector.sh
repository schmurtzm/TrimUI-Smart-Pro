#!/bin/sh
echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

RA_DIR=/mnt/SDCARD/RetroArch
cd $RA_DIR
HOME=$RA_DIR/ $RA_DIR/ra64.trimui --appendconfig  "$RA_DIR/.retroarch/database/rdb/Sony - PlayStation - analog/Sony - PlayStation - analog.cfg"  --scan=/mnt/SDCARD/Roms/PS


analog_count="/tmp/analog_count"
echo 0 >"$analog_count"

mkdir -p "$RA_DIR/.retroarch/config/remaps/PCSX-ReARMed"
mkdir -p "$RA_DIR/.retroarch/config/remaps/DuckStation"
mkdir -p "$RA_DIR/.retroarch/config/remaps/SwanStation"

/mnt/SDCARD/System/bin/sdl2imgshow \
  -i "/usr/trimui/res/skin/bg.png" \
  -f "/usr/trimui/res/regular.ttf" \
  -s 50 \
  -c "220,220,220" \
  -t "Detecting Dual Shock compatible games..." &

# Traverse the "Sony - PlayStation.lpl" file with jq
/mnt/SDCARD/System/bin/jq -r '.items[] | .crc32, .label, .path' "$RA_DIR/.retroarch/playlists/Sony - PlayStation - analog.lpl" |
  while IFS= read -r crc32; do
    IFS= read -r label
    IFS= read -r path

      # Create file path with .rmp extension
      count=$(cat "$analog_count")
      count=$((count + 1))
      echo "$count" >"$analog_count"
      filename=$(basename "$path")
      filename="${filename%.*}.rmp"
      # ========= PCSX-ReARMed
      filepath="$RA_DIR/.retroarch/config/remaps/PCSX-ReARMed/$filename"
      echo "Applying Dual Shock to $filename for PCSX-ReARMed"
      if [ -e "$filepath" ]; then
        configPatchFile="/tmp/$filename"
        echo 'input_libretro_device_p1 = "517"' >"$configPatchFile"
        /mnt/SDCARD/System/usr/trimui/scripts/patch_ra_cfg.sh "$configPatchFile" "$filepath"
        rm "$configPatchFile"
      else
        # Write content to the file
        echo 'input_libretro_device_p1 = "517"' >"$filepath"
      fi
      # ========= Duckstation
      filepath="$RA_DIR/.retroarch/config/remaps/DuckStation/$filename"
      echo "Applying Dual Shock to $filename for PCSX-ReARMed"
      if [ -e "$filepath" ]; then
        configPatchFile="/tmp/$filename"
        echo 'input_libretro_device_p1 = "5"' >"$configPatchFile"
        /mnt/SDCARD/System/usr/trimui/scripts/patch_ra_cfg.sh "$configPatchFile" "$filepath"
        rm "$configPatchFile"
      else
        # Write content to the file
        echo 'input_libretro_device_p1 = "5"' >"$filepath"
      fi
      # ========= Swantation
      filepath="$RA_DIR/.retroarch/config/remaps/SwanStation/$filename"
      echo "Applying Dual Shock to $filename for SwanStation"
      if [ -e "$filepath" ]; then
        configPatchFile="/tmp/$filename"
        echo 'input_libretro_device_p1 = "517"' >"$configPatchFile"
        /mnt/SDCARD/System/usr/trimui/scripts/patch_ra_cfg.sh "$configPatchFile" "$filepath"
        rm "$configPatchFile"
      else
        # Write content to the file
        echo 'input_libretro_device_p1 = "517"' >"$filepath"
      fi
  done
  
rm "$RA_DIR/.retroarch/playlists/Sony - PlayStation - analog.lpl"
  
sync

echo "Number of successful path finds: $(cat "$analog_count")"

pkill -f sdl2imgshow
sleep 0.3
/mnt/SDCARD/System/bin/sdl2imgshow \
  -i "/usr/trimui/res/skin/bg.png" \
  -f "/usr/trimui/res/regular.ttf" \
  -s 50 \
  -c "220,220,220" \
  -t "$(cat "$analog_count") analog compatible game(s) detected." &

sleep 4
pkill -f sdl2imgshow
rm "$analog_count"
