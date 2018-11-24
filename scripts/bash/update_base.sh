#!/usr/bin/env bash

if [[ $1 == "help" || $1 == "--help" || $1 == "-h" ]]; then
	echo "Minetest Gameupdate bash v1.0 (license GPLv3.0 or later)"
	echo ""
	echo "Description:"
	echo "\tThis script updates the configured game from its base repository as defined by gameupdate.conf in the root of the repository and tries its best to reso've conflicts and keep changes from both repositories."
	echo ""
	echo "Usage:"
	echo "update_base.sh [help|--help|-h]"
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
	echo "Finished! No stashing needed, repos don't conflict."
	cd $SWD
	return 0
fi

# now for the nonsense
git stash
git pull $base_repo
if [[ $? != 0 ]]; then
	echo "Something went wrong, failed to pull $base_repo after stashing changes."
	cd $SWD
	return 1
fi
git stash pop
if [[ $? != 0 ]]; then
	echo "Game base updated successfully! Have fun!"
	cd $SWD
	return 0
else
	echo "Something went wrong when poping the stash, some manual reworking may be necessary or you may have broken something, who knows."
	cd $SWD
	return 2
fi
