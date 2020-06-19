#!/bin/bash

# Current path (full path required when building from the remote spectre app)
SPECTRE_ENGINE_PATH=.
if [ $1 ] && [ ${#1} -gt 0 ]; then
  SPECTRE_ENGINE_PATH="$1"
fi

## Testing for Preferences availability
if test -f "$SPECTRE_ENGINE_PATH/public/preferences.json"; then
  echo "Configuration file ready.."
else
  $cprint error "[ERROR] Could not find a usable configuration file."
  exit 1
fi

## Constants
DEFAULT_OUTPUT_PATH="$SPECTRE_ENGINE_PATH/dist"
APPLICATIONS_FOLDER="/Applications"
ICON_PATH="$SPECTRE_ENGINE_PATH/public/icon.png"
PREFERENCES_PATH="$SPECTRE_ENGINE_PATH/public/preferences.json"
DEFAULT_ICON_PATH="$SPECTRE_ENGINE_PATH/assets/icons/png/spectre-high-res.png"
REPOSITORY_URL="https://github.com/vbuzzegoli/spectre"
CUSTOM_IMAGE_PATH=$(node -p -e "require('$SPECTRE_ENGINE_PATH/public/preferences.json').imagePath")
CUSTOM_IMAGE_URL=$(node -p -e "require('$SPECTRE_ENGINE_PATH/public/preferences.json').imageUrl")
APP_NAME=$(node -p -e "require('$SPECTRE_ENGINE_PATH/public/preferences.json').title")
USE_APPLICATION_FOLDER=$(node -p -e "require('$SPECTRE_ENGINE_PATH/public/preferences.json').useApplicationFolder")

## Helpers
cprint="$SPECTRE_ENGINE_PATH/scripts/helpers/cprint.sh"
generateIcns="$SPECTRE_ENGINE_PATH/scripts/helpers/generateIcns.sh"

clearCachedFiles () {
  rm -rf "$SPECTRE_ENGINE_PATH/appIcon.icns"
  rm -rf "$SPECTRE_ENGINE_PATH/appIcon.iconset"
  rm -f $ICON_PATH
}


## Process

## Packaging
$cprint secondary "==> Creating Application.."

$cprint neutral "Verifying configuration.."
if [ ! $APP_NAME ] || [ "$APP_NAME" = "undefined" ] || [ ${#APP_NAME} -eq 0 ]; then
  $cprint error "[ERROR] Invalid name provided."
  exit 1
fi
if [ "$USE_APPLICATION_FOLDER" != "false" ]; then
  USE_APPLICATION_FOLDER=true
fi

$cprint neutral "Clearing previous build.."
rm -rf "$SPECTRE_ENGINE_PATH/dist" # Not using $DEFAULT_OUTPUT_PATH as this cmd could otherwise be potentially harmful
clearCachedFiles


$cprint neutral "Generating App Icon.."
if [ $CUSTOM_IMAGE_URL ] && [ "$CUSTOM_IMAGE_URL" != "undefined" ] && [ ${#CUSTOM_IMAGE_URL} -gt 0 ]; then
  {
    $cprint neutral "Fetching icon.."
    curl "$CUSTOM_IMAGE_URL" > $ICON_PATH
  } || {
    $cprint error "[WARNING] Unable to fetch icon. Using fallback icon instead.."
    cp $DEFAULT_ICON_PATH $ICON_PATH
  }
elif [ $CUSTOM_IMAGE_PATH ] && [ "$CUSTOM_IMAGE_PATH" != "undefined" ] && [ ${#CUSTOM_IMAGE_PATH} -gt 0 ]; then
  {
      customIconFileName="${CUSTOM_IMAGE_PATH##*/}"
      customIconFileExtension="${customIconFileName##*.}"
      if [ ${#customIconFileExtension} -gt 0 ] && [ $customIconFileExtension = 'png' ]; then
        $cprint neutral "Using custom icon.."
        cp $CUSTOM_IMAGE_PATH $ICON_PATH
      else
        $cprint error "[WARNING] Unable to use the icon at the provided path. Using fallback icon instead.."
        cp $DEFAULT_ICON_PATH $ICON_PATH
      fi
    } || {
      $cprint error "[WARNING] Unable to use the icon at the provided path. Using fallback icon instead.."
      cp $DEFAULT_ICON_PATH $ICON_PATH
    }
else
  $cprint neutral "Using default icon.."
  cp $DEFAULT_ICON_PATH $ICON_PATH
fi



$cprint neutral "Packaging Application.."
{
  $generateIcns $ICON_PATH appIcon
} || {
  $cprint error "[WARNING] Unable to setup icon."
}
electron-packager "$SPECTRE_ENGINE_PATH" "$APP_NAME" --out=$DEFAULT_OUTPUT_PATH --asar --platform=darwin --darwin-dark-mode-support --icon="$SPECTRE_ENGINE_PATH/appIcon.icns"

$cprint neutral "Renaming distribution.."
for targetDirectory in `ls $DEFAULT_OUTPUT_PATH`; do 
  mv "$DEFAULT_OUTPUT_PATH/$targetDirectory" "$DEFAULT_OUTPUT_PATH/application"; # rename single output to predictable name, independent of CPU architecture
done


$cprint neutral "Clearing cached files.."
clearCachedFiles



## Staging
$cprint secondary "==> Staging Application.."

didMoveToApplications=false
if [ "$USE_APPLICATION_FOLDER" = "true" ]; then
  {
    $cprint neutral "Moving application to Applications folder.."
    if [ ! -d "$APPLICATIONS_FOLDER/$APP_NAME.app" ]; then
      mv "$DEFAULT_OUTPUT_PATH/application/$APP_NAME.app" "$APPLICATIONS_FOLDER/$APP_NAME.app"
      $cprint neutral "Clearing cached artifacts.."
      rm -rf "$SPECTRE_ENGINE_PATH/dist" # Not using $DEFAULT_OUTPUT_PATH as this cmd could otherwise be potentially harmful
      didMoveToApplications=true
    else
      $cprint error "[WARNING] Application could not be moved to /Applications as another application already has the same name in this folder."
    fi
  } || {
    $cprint error "[WARNING] Unable to complete operation."
    exit 1
  }
  doneMessage="[DONE] Application successfully created (available in your /Applications folder)"
else
  doneMessage="[DONE] Application successfully created (available at $SPECTRE_ENGINE_PATH/dist)"
fi



## Done 
if [ "$didMoveToApplications" = "true" ]; then
  $cprint success "[DONE] Application successfully created (available in your /Applications folder)"
  $cprint neutral "-> Launching application..\n"
  open "$APPLICATIONS_FOLDER/$APP_NAME.app"
else
  $cprint success "[DONE] Application successfully created (available at $SPECTRE_ENGINE_PATH/dist)"
  $cprint neutral "-> Launching application..\n"
  open "$DEFAULT_OUTPUT_PATH/application/$APP_NAME.app"
fi

$cprint info "-> If you like Spectre please consider making a donation: $REPOSITORY_URL#support \n"




