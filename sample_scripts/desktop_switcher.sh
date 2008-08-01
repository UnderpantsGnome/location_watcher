#!/bin/bash
# 
# you can use this script to switch your desktop background by location
#
# usage: 
#   in your ~/bin/location_watcher/location script add the following
#
#   cd `dirname $0`
#   ./desktop_switcher.sh some_image_file.jpg
#
#   limitations: 
#   the script currently assumes all your images are under ~/Pictures becasue
#   well, that's where Apple thinks they should be and that's where I keep stuff
#

# set this to your login name
LOCAL_USER=your_login_name

if [ "${1}" ]; then
  # read out the desktop plist and write it to a temp file since it's binary
  defaults read /Users/${LOCAL_USER}/Library/Preferences/com.apple.desktop > /tmp/com.apple.desktop.temp

  # do the replacement and write it back to the Users plist
  sed "s:/Pictures/.*\":/Pictures/${1}\":" < /tmp/com.apple.desktop.temp > /Users/${LOCAL_USER}/Library/Preferences/com.apple.desktop.plist

  # clean up
  rm /tmp/com.apple.desktop.temp

  # TODO: try to find a way to get Finder to reread the desktop plist without 
  # killing the dock
  # kick the dock to make the change happen
  killall Dock
fi
