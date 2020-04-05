#!/bin/bash

## Constants
DEFAULT_OUTPUT_PATH="./dist"
APPLICATIONS_FOLDER="/Applications"
ICON_PATH="./public/icon.png"
PREFERENCES_PATH="./public/preferences.json"
DEFAULT_ICON_PATH="./assets/icons/png/spectre-high-res.png"
PRESETS_PATH="./presets.js"
REPOSITORY_URL="https://github.com/vbuzzegoli/spectre"
PACKAGE_VERSION=$(node -p -e "require('./package.json').version")

## Helpers
cprint=./scripts/helpers/cprint.sh
ask=./scripts/helpers/ask.sh
heading=./scripts/helpers/heading.sh
generateIcns=./scripts/helpers/generateIcns.sh

clearCachedFiles () {
  rm -rf ./appIcon.icns
  rm -rf ./appIcon.iconset
  rm -f $ICON_PATH
  rm -f $PREFERENCES_PATH
}


## Process

$heading

$cprint neutral "Version: $PACKAGE_VERSION"

# Configuration
$cprint secondary "[1/3] Configuring Application.."

# - App Name
$ask "- App name:" ; read -p "" name ;
name=${name// /\-} # escape spaces
if [ ${#name} -lt 1 ]; then
  $cprint error "The name provided seems invalid. Please try again."
  return
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
    return
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



## Packaging
$cprint secondary "[2/3] Creating Application.."

$cprint neutral "Clearing previous build.."
rm -rf ./dist # Not using $DEFAULT_OUTPUT_PATH as this cmd could otherwise be potentially harmful
clearCachedFiles


$cprint neutral "Generating App Icon.."
if [ "$useWebIcon" = "true" ]; then
{
  $cprint neutral "Fetching icon.."
  if [ $imageUrl ] && [ ${#imageUrl} -gt 0 ]; then
    curl "$imageUrl" > $ICON_PATH
  else
    $cprint error "[WARNING] Unable to fetch icon. Using fallback icon instead.."
    cp $DEFAULT_ICON_PATH $ICON_PATH
  fi
} || {
  $cprint error "[WARNING] Unable to fetch icon. Using fallback icon instead.."
  cp $DEFAULT_ICON_PATH $ICON_PATH
}
elif [ "$useCustomIcon" = "true" ]; then
  if [ ${#imagePath} -gt 0 ]; then
    {
      customIconFileName="${imagePath##*/}"
      customIconFileExtension="${customIconFileName##*.}"
      if [ ${#customIconFileExtension} -gt 0 ] && [ $customIconFileExtension = 'png' ]; then
        $cprint neutral "Using custom icon.."
        cp $imagePath $ICON_PATH
      else
        $cprint error "[WARNING] Unable to use the icon at the provided path. Using fallback icon instead.."
        cp $DEFAULT_ICON_PATH $ICON_PATH
      fi
    } || {
      $cprint error "[WARNING] Unable to use the icon at the provided path. Using fallback icon instead.."
      cp $DEFAULT_ICON_PATH $ICON_PATH
    }
  else
    $cprint error "[WARNING] Unable to use the icon at the provided path. Using fallback icon instead.."
    cp $DEFAULT_ICON_PATH $ICON_PATH
  fi
else
  $cprint neutral "Using default icon.."
  cp $DEFAULT_ICON_PATH $ICON_PATH
fi

$cprint neutral "Writing Preferences.."
{
  json="{"
  if [ "$customSize" = "true" ]; then
    if [ $width ] && [ $width -gt 0 ]; then
      json="$json width:${width},"
    fi
    if [ $height ] && [ $height -gt 0 ]; then
      json="$json height:${height},"
    fi
  fi
  json="$json \"url\":\"${url}\",\"ghostMode\":${ghost},\"fullscreen\":${fullscreen},\"title\":\"${name}\"}" > $PREFERENCES_PATH
  echo "$json" > $PREFERENCES_PATH
} || {
  $cprint error "[ERROR] Unable to write preferences. Exiting.."
  rm -rf ./dist # Not using $DEFAULT_OUTPUT_PATH as this cmd could otherwise be potentially harmful
  clearCachedFiles
  exit 0
}

$cprint neutral "Packaging Application.."
{
  $generateIcns $ICON_PATH appIcon
} || {
  $cprint error "[WARNING] Unable to setup icon."
}
electron-packager . "$name" --out=$DEFAULT_OUTPUT_PATH --asar --platform=darwin --darwin-dark-mode-support --icon=./appIcon.icns

$cprint neutral "Renaming distribution.."
for targetDirectory in `ls $DEFAULT_OUTPUT_PATH`; do 
  mv "$DEFAULT_OUTPUT_PATH/$targetDirectory" "$DEFAULT_OUTPUT_PATH/application"; # rename single output to predictable name, independent of CPU architecture
done


$cprint neutral "Clearing cached files.."
clearCachedFiles



## Staging
$cprint secondary "[3/3] Staging Application.."

didMoveToApplications=false
if [ "$useApplicationFolder" = "true" ]; then
  {
    $cprint neutral "Moving application to Applications folder.."
    if [ ! -d "$APPLICATIONS_FOLDER/$name.app" ]; then
      mv "$DEFAULT_OUTPUT_PATH/application/$name.app" "$APPLICATIONS_FOLDER/$name.app"
      $cprint neutral "Clearing cached artifacts.."
      rm -rf ./dist # Not using $DEFAULT_OUTPUT_PATH as this cmd could otherwise be potentially harmful
      didMoveToApplications=true
    else
      $cprint error "[WARNING] Application could not be moved to /Applications as another application already has the same name in this folder."
    fi
  } || {
    $cprint error "[WARNING] Unable to complete operation."
    exit 0
  }
  doneMessage="[DONE] Application successfully created (available in your /Applications folder)"
else
  doneMessage="[DONE] Application successfully created (available at ./dist)"
fi



## Done 
if [ "$didMoveToApplications" = "true" ]; then
  $cprint success "[DONE] Application successfully created (available in your /Applications folder)"
  $cprint neutral "-> Launching application..\n"
  open "$APPLICATIONS_FOLDER/$name.app"
else
  $cprint success "[DONE] Application successfully created (available at ./dist)"
  $cprint neutral "-> Launching application..\n"
  open "$DEFAULT_OUTPUT_PATH/application/$name.app"
fi

$cprint info "-> If you like Spectre please consider making a donation: $REPOSITORY_URL#support \n"




