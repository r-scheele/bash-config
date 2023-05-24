#!/bin/bash

source ~/bash-config/common.sh

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

source /Users/cniackz/.docker/init-bash.sh || true # Added by Docker Desktop

# Brew
eval $(/opt/homebrew/bin/brew shellenv)


##
# Your previous /Users/cniackz/.bash_profile file was backed up as /Users/cniackz/.bash_profile.macports-saved_2023-05-19_at_08:20:06
##

# MacPorts Installer addition on 2023-05-19_at_08:20:06: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# MacPorts Installer addition on 2023-05-19_at_08:20:06: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

