#!/usr/bin/env bash

if [[ $1 == "help" || $1 == "--help" || $1 == "-h" ]]; then
	echo "Minetest Gameupdate bash v1.0 (license GPLv3.0 or later)"
	echo ""
	echo "Description:"
	echo "\tThis script updates the configured game to its latest git commits. simple wrapper for git pull but here for possible future usefulness."
	echo ""
	echo "Usage:"
	echo "update_game.sh [help|--help|-h]"
	echo "\thelp|--help|-h\t show this help message and quit"
	return 0
fi

# read values from configuration file
IFS="=|#"
while read -r key value comments
do
	export $key=$value
done < ../gameupdate.conf

# some additional variables will be set for coding convenience
SWD=$(pwd)

# cd to where the game is
cd $game_path

# Now that we have configuration options it is time to stash the changes
# pull first just in case non of this nonsense is needed
git pull $base_repo
if [[ $? != 0 ]]; then
	echo "Finished! Repos don't conflict."
	cd $SWD
	return 0
else
	echo "Something has went wrong, you may have uncommited changes that need to be stashed or may have misconfigured something. Check gameupdate.conf in the root of the repository for errors and try again or maybe run update_base.sh to update the game's base"
	cd $SWD
	return 1
fi
