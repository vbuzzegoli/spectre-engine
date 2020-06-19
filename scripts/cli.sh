#!/bin/bash

## Constants
DEFAULT_OUTPUT_PATH="./dist"
PREFERENCES_PATH="./public/preferences.json"
PRESETS_PATH="./presets.js"
PACKAGE_VERSION=$(node -p -e "require('./package.json').version")

## Helpers
cprint=./scripts/helpers/cprint.sh
ask=./scripts/helpers/ask.sh
heading=./scripts/helpers/heading.sh

clearCachedFiles () {
  rm -f $PREFERENCES_PATH
}


### Process

$heading

$cprint neutral "Version: $PACKAGE_VERSION"

## Configuration
$cprint secondary "==> Configuring Application.."

# - App Name
$ask "- App name:" ; read -p "" name ;
name=${name// /\-} # escape spaces
if [ ${#name} -lt 1 ]; then
  $cprint error "The name provided seems invalid. Please try again."
  exit 1
fi

# Presets
usePreset=false
{
  presetExists=$(node -p -e "require('$PRESETS_PATH').exists('$name')")
  if [ $presetExists ] && [ "$presetExists" = "true" ]; then
    $ask "- [PRESET FOUND] Do you want to use the preset information for this application: (y/n)" "yes"; read -p "" usePreset ;
    if [ ! $usePreset ] || [ $usePreset != "n" ]; then usePreset=true ; else usePreset=false ; fi
    if [ "$usePreset" = "true" ]; then
      url=$(node -p -e "require('$PRESETS_PATH').getUrlOf('$name')")
      imageUrl=$(node -p -e "require('$PRESETS_PATH').getIconUrlOf('$name')")
      useWebIcon=true
    fi
  fi
} || {
  $cprint error "Error during preset detection"
}

# - Web URL
if [ "$usePreset" = "false" ]; then
  $ask "- Web URL:" ; read -p "" url ; protocol="${url:0:4}" ;
  if [ ! $url ] || [ $protocol != "http" ]; then
    $cprint error "The URL provided seems invalid. Please try again."
    exit 1
  fi
fi

# - Use Applications Folder
$ask "- Add to the Applications folder: (y/n)" "yes"; read -p "" useApplicationFolder ;
if [ ! $useApplicationFolder ] || [ $useApplicationFolder != "n" ]; then useApplicationFolder=true ; else useApplicationFolder=false ; fi

# - Use WebApp Icon
if [ "$usePreset" = "false" ]; then
  $ask "- Use image from web as icon: (y/n)" "yes"; read -p "" useWebIcon ;
  if [ ! $useWebIcon ] || [ $useWebIcon != "n" ]; then useWebIcon=true ; else useWebIcon=false ; fi
  if [ "$useWebIcon" = "true" ]; then
    $ask " -- Icon URL (.png only - ex: https://www.ggogle.com/myImage.png): " ; read -p "" imageUrl ;
  fi
fi

# - Use Local Icon
if [ "$usePreset" = "false" ] && [ "$useWebIcon" = "false" ]; then
  $ask "- Use local image as icon: (y/n)" "no"; read -p "" useCustomIcon ;
  if [ $useCustomIcon ] && [ $useCustomIcon = "y" ]; then useCustomIcon=true ; else useCustomIcon=false ; fi
  if [ "$useCustomIcon" = "true" ]; then
    $ask " -- full path (.png only - ex: /Documents/myImage.png): " ; read -p "" imagePath ;
  fi
fi

# - Fullscreen
$ask "- Launch in fullscreen: (y/n)" "no";  read -p "" fullscreen ;
if [ $fullscreen ] && [ $fullscreen = "y" ]; then fullscreen=true ; else fullscreen=false ; fi

if [ "$fullscreen" = "false" ]; then
  # - Custom Size
  $ask "- Launch with custom size: (y/n)" "no"; read -p "" customSize ;
  if [ $customSize ] && [ $customSize = "y" ]; then customSize=true ; else customSize=false ; fi
  if [ "$customSize" = "true" ]; then
    $ask " - Width (px): " ; read -p "" width ;
    $ask " - Height (px): " ; read -p "" height ;
  fi
fi

# - Ghost Mode
$ask "- Enable ghost mode (frameless): (y/n)" "no"; read -p "" ghost ;
if [ $ghost ] && [ $ghost = "y" ]; then ghost=true ; else ghost=false ; fi



## Writing 
$cprint secondary "==> Setting up environment.."

$cprint neutral "Clearing previous configuration.."
rm -f $PREFERENCES_PATH

$cprint neutral "Writing Configuration Files.."
{
  json="{"
  if [ "$customSize" = "true" ]; then
    if [ $width ] && [ $width -gt 0 ]; then
      json="$json \"width\":${width},"
    fi
    if [ $height ] && [ $height -gt 0 ]; then
      json="$json \"height\":${height},"
    fi
  fi
  if [ "$useWebIcon" = "true" ] && [ $imageUrl ] && [ ${#imageUrl} -gt 0 ]; then
    json="$json \"imageUrl\":\"${imageUrl}\","
  elif [ "$useCustomIcon" = "true" ]; then
    customIconFileName="${imagePath##*/}"
    customIconFileExtension="${customIconFileName##*.}"
    if [ ${#customIconFileExtension} -gt 0 ] && [ $customIconFileExtension = 'png' ]; then
      json="$json \"imagePath\":\"${imagePath}\","
    fi
  fi
  json="$json \"url\":\"${url}\",\"ghostMode\":${ghost},\"fullscreen\":${fullscreen},\"title\":\"${name}\",\"useApplicationFolder\":\"${useApplicationFolder}\"}" > $PREFERENCES_PATH
  echo "$json" > $PREFERENCES_PATH
} || {
  $cprint error "[ERROR] Unable to write configuration. Exiting.."
  rm -f $PREFERENCES_PATH
  exit 1
}
