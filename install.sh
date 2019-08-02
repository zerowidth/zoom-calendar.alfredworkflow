#!/bin/bash

set -e

# prerequisites:
which icalBuddy > /dev/null|| {
  echo "icalBuddy not found: brew install ical-buddy"
  exit 1
}

prefs=~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist
syncfolder=$(/usr/libexec/PlistBuddy -c "print :syncfolder" $prefs 2>/dev/null || echo)
if [ -z "$syncfolder" ]; then
  syncfolder=~/Library/Application\ Support/Alfred
fi

workflows=$syncfolder/Alfred.alfredpreferences/workflows
workflows=${workflows/\~/$HOME} # expand ~/

if [ -d "$workflows" ]; then
  echo "symlinking $(pwd) into $workflows"
  ln -s "$(pwd)" "$workflows"
else
  echo "Could not find workflows folder: $workflows"
  exit 1
fi
