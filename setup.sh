#!/bin/bash

BASH_PROFILE=~/.bash_profile
BASHRC=~/.bashrc
ZSHRC=~/.zshrc
DIRNAME="$( dirname "${BASH_SOURCE[0]}" &> /dev/null && pwd )"

function add_alias {
   printf "\nalias kb=$DIRNAME/script.rb\n" >> $1
   printf "\nalias cl=\"~/projects/utils/kb/wrapper.sh\"" >> $1
   echo "export GEM_HOME=\"$HOME/.gem\"" >> $1
   source $1
   gem install bundler && bundle

   exit 0;
}

if [[ -f $ZSHRC ]]; then 
   add_alias $ZSHRC;
elif [[ -f $BASH_PROFILE ]]; then
   add_alias $BASH_PROFILE;
elif [[ -f $BASHRC ]]; then
    add_alias $BASHRC;
else 
   echo "No candidates for a script found - exiting script";
fi
