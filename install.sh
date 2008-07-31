#!/bin/bash

echo "installing location_watcher"
if [ ! -e "${HOME}/bin/location_watcher" ]; then
  echo "creating ~/bin/location_watcher"
  mkdir -p ~/bin/location_watcher
fi

echo "writing ~/bin/location_watcher.sh"
sed "s:HOME_DIR:${HOME}:g;s:GROWL_PATH:`which growlnotify`:" < ./location_watcher.sh > ~/bin/location_watcher.sh

if [ ! -e "${HOME}/Library/LaunchAgents" ]; then
  echo "creating ~/Library/LaunchAgents"
  mkdir -p ~/Library/LaunchAgents
fi

# take ownership of the file
sudo chown ${USER}:wheel ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist

# install a new one pointing to our local script
echo "writing ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist"
sed "s:HOME_DIR:${HOME}:g" < ./com.underpantsgnome.location_watcher.plist > ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist

# give the file back to root or it wont load
sudo chown root:wheel ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist

# tell launchd to unload it to pickup any changes
echo "unloading ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist"
sudo launchctl unload ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist

# tell launchd to load it
echo "loading ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist"
sudo launchctl load ~/Library/LaunchAgents/com.underpantsgnome.location_watcher.plist

if [ ! -e "${HOME}/.location_watcher" ]; then
  echo "creating ~/.location_watcher"
  cp ./location_watcher ~/.location_watcher
fi
