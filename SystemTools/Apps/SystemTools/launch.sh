#!/bin/sh
echo $0 $*

echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1416000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

/mnt/SDCARD/System/bin/sdl2imgshow \
  -i "/usr/trimui/res/skin/bg.png" \
  -f "/usr/trimui/res/regular.ttf" \
  -s 50 \
  -c "220,220,220" \
  -t "Building Menu..." &
sleep 0.2
pkill -f sdl2imgshow

PATH="/mnt/SDCARD/System/bin:$PATH"
export LD_LIBRARY_PATH="/mnt/SDCARD/System/lib:/usr/trimui/lib:$LD_LIBRARY_PATH"
database_file="/mnt/SDCARD/Apps/SystemTools/Menu/Menu_cache7.db"
CurrentTheme=$(/mnt/SDCARD/System/bin/jq -r .theme /mnt/UDISK/system.json)
mkdir -p  /mnt/SDCARD/System/starts/
mkdir -p  /mnt/SDCARD/System/etc
if [ ! -f "/mnt/SDCARD/System/etc/systemtools.json" ]; then
touch /mnt/SDCARD/System/etc/systemtools.json
fi


SubFoldersList=":"
####################################### For testing :
rm "$database_file"
#######################################

cp /mnt/SDCARD/Apps/SystemTools/GoTo_SystemTools_List.json /tmp/state.json
sync

# We re-create the database only if it doesn't exist...
if [ -f "$database_file" ]; then
  exit
fi
img_path="/mnt/SDCARD/Apps/SystemTools/Menu/Imgs"
	
# ================================================= Create a new database file =================================================

sqlite3 "$database_file" "CREATE TABLE Menu_roms (id INTEGER PRIMARY KEY, disp TEXT, path TEXT, imgpath TEXT, type INTEGER, ppath TEXT, pinyin TEXT, cpinyin TEXT, opinyin TEXT);"
sync

# ================================================= Create folders items in database =================================================
# Scan files in the rompath directory
search_path="/mnt/SDCARD/Apps/SystemTools/Menu/"

for folder in "$search_path"/*/; do
  # Extract the folder name
  folder_name=$(basename "$folder")

  # Check if the folder is the "Imgs" directory
  if [ "$folder_name" = "Imgs" ]; then
    # Skip the "Imgs" directory
    continue
  fi

  if [ "${subfolder%/}" = "${search_path%/}" ]; then
    ppath="."
  else
    ppath="${subfolder##*/}"
    folder_escaped=$(echo "$folder_name" | sed "s/'/''/g")
  fi

  # Create an entry for the folder as if it were a game
  subfolder_query="INSERT INTO Menu_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (\"$folder_escaped\", \"$folder\", \"${img_path}/${folder_name}.png\", 1, \".\", \"$folder_escaped\", \"$folder_escaped\", \"$folder_escaped\")"
  sqlite3 "$database_file" "$subfolder_query"
  sync
done

# ================================================= Create script items in database =================================================

# find "$search_path" -mindepth 1 -maxdepth 2 -type f | while read -r file; do
find "$search_path" -mindepth 1 -maxdepth 2 -type f -name "*.sh" | while read -r file; do
  # Skip files starting with a dot (.)
  filename=$(basename "$file")
  if [ "${filename#.*}" != "$filename" ]; then
    continue
  fi

  filename_without_ext="${filename%.*}"

  # Escape single quotes in the filename
  escaped_filename=$(echo "$filename_without_ext" | sed "s/'/''/g")

  if [ "$escaped_filename" = "Default" ]; then
    escaped_filename=" $escaped_filename"
  fi

  # Determine the subfolder (ppath)
  subfolder=$(dirname "$file")
  if [ "${subfolder%/}" = "${search_path%/}" ]; then
    ppath="."
  else
    ppath="${subfolder##*/}"
  fi

  # Set the imgpath with the subfolder "Imgs"
  imgpath="$img_path/$(basename "$subfolder")/${filename%.*}.png"

  # Prepare the SQLite query with double quotes around the filename, ppath, and imgpath
  query="INSERT INTO Menu_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (\"$escaped_filename\", \"$file\", \"$imgpath\", 0, \"$ppath\", \"$escaped_filename\", \"$escaped_filename\", \"$escaped_filename\")"

  # Execute the query using sqlite3
  sqlite3 "$database_file" "$query"
  sync

  echo "Entry created for file: $file"

done

sync
# ================================================= Create subfolders hierarchy in database =================================================

echo "database_file= $database_file"

# select all folder containing "##"
sqlite3 "$database_file" "SELECT path FROM Menu_roms WHERE path LIKE '%##%' AND type = 1;" |
  while IFS= read -r path; do
    subdir_name=$(basename "$path")
    parentFolder="${subdir_name%%##*}"
    subFolder="${subdir_name#*##}"
    echo "---"
    echo "Folder full path: $path"
    echo "parentFolder: $parentFolder"
    echo "subFolder: $subFolder"

    # Create folder hierarchy
    sqlite3 "$database_file" "UPDATE Menu_roms SET disp = '$subFolder',pinyin = '$subFolder',cpinyin = '$subFolder',opinyin = '$subFolder' , ppath = '$parentFolder' WHERE path = '$path';"

    # Change each script item with new virtual subfolder
    sqlite3 "$database_file" "UPDATE Menu_roms SET ppath = '$subFolder' WHERE ppath = '$subdir_name';"
  done
sync

# ============================================== Modify folders which requires a "state" value ==============================================
echo "================"
# Get current state of the option
sqlite3 "$database_file" "SELECT disp, path FROM Menu_roms WHERE type = 1 AND disp LIKE '% (state)' ;" |
  while IFS='|' read -r disp path; do
    disp_withoutstate=$(echo "$disp" | sed 's/ (state)//g')
    CurState=$(jq -r --arg disp "$disp_withoutstate" '.[$disp] // 1' "/mnt/SDCARD/System/etc/systemtools.json")
	echo "-*-*--**-*-*-*-*-*-*--*-*-*-*-XXX $CurState"
	if [ -z "$CurState" ]; then
    CurState="not set"
fi
    # ----------------------------------------------------------------------
    # Managing some exceptions : state values related to the current theme :
    if [ "$disp_withoutstate" = "CLICK" ]; then
      if [ -e "$CurrentTheme/sound/click.wav" ]; then
        CurState=1
      elif [ -e "$CurrentTheme/sound/click-off.wav" ]; then
        CurState=0
      else
        CurState="not av."
      fi
    fi
    if [ "$disp_withoutstate" = "MUSIC" ]; then
      if [ -e "$CurrentTheme/sound/bgm.mp3" ]; then
        CurState=1
      elif [ -e "$CurrentTheme/sound/bgm-off.mp3" ]; then
        CurState=0
      else
        CurState="not av."
      fi
    fi
    if [ "$disp_withoutstate" = "TOP LEFT LOGO" ]; then
      if [ -e "$CurrentTheme/skin/nav-logo-off.png" ]; then
        CurState=0
      else
        CurState=1
      fi
    fi
    # ----------------------------------------------------------------------

    if [ "$CurState" -eq 1 ] || [ "$CurState" = "null" ]; then
      disp_withstate="$disp_withoutstate (enabled)"
    else
      disp_withstate="$disp_withoutstate (disabled)"
    fi

    sqlite3 "$database_file" "UPDATE Menu_roms SET disp = '$disp_withstate',pinyin = '$disp_withstate',cpinyin = '$disp_withstate',opinyin = '$disp_withstate'  WHERE path = '$path';"
    sqlite3 "$database_file" "UPDATE Menu_roms SET ppath = '$disp_withstate' WHERE ppath = '$disp';"

    echo "==== Updated \"$disp_withoutstate\" to \"$disp_withstate\""
  done

# ============================================== Modify folders which requires a "value" value ==============================================

sqlite3 "$database_file" "SELECT disp, path FROM Menu_roms WHERE type = 1 AND disp LIKE '% (value)' ;" |
  while IFS='|' read -r disp path; do
    disp_withoutvalue=$(echo "$disp" | sed 's/ (value)//g')
    CurState=$(jq -r --arg disp "$disp_withoutvalue" '.[$disp] // "Default"' "/mnt/SDCARD/System/etc/systemtools.json")
		if [ -z "$CurState" ]; then
    CurState="not set"
fi
    disp_withvalue="$disp_withoutvalue ($CurState)"
    sqlite3 "$database_file" "UPDATE Menu_roms SET disp = '$disp_withvalue',pinyin = '$disp_withvalue',cpinyin = '$disp_withvalue',opinyin = '$disp_withvalue' WHERE path = '$path';"
    sqlite3 "$database_file" "UPDATE Menu_roms SET ppath = '$disp_withvalue' WHERE ppath = '$disp';"

    echo "==== Updated \"$disp_withoutvalue\" to \"$disp_withvalue\""
  done

sync
