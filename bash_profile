source common.sh

######################################
#
# Aliases only for my Mac System
#
######################################
if [ ! -f /usr/local/bin/subl ]
then
  echo "subl not found, creating link for it"
  sudo ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
fi
