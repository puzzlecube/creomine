#!/usr/bin/env bash

if [[ $1 == "help" || $1 == "--help" || $1 == "-h" ]]; then
	echo "Minetest Gameupdate bash v1.0 (license GPLv3.0 or later)"
	echo ""
	echo "Description:"
	echo "\tThis script updates the configured game's base to latest git and also updates ALL mods reguardless of if you want a mod to stay where it is for some odd reason or not. Run at your own risk!"
	echo ""
	echo "Usage:"
	echo "full_update.sh [help|--help|-h][verbose|--verbose|-v]"
	echo "\thelp|--help|-h\t show this help message and quit"
	echo "\tverbose|--verbose|-v\t print the status of everything that happens. Yes I mean everything."
	return 0
fi

# read values from configuration file
IFS="=|#"
while read -r key value comments
do
	export $key=$value
done < ../gameupdate.conf

# some additional variables will be set for coding convenience
MODS=$game_path/mods
SWD=$(pwd)

# echo only if verbose mode is on
function vecho() {
	if [[ $1 == "verbose" || $1 == "--verbose" || $1 == "-v" ]]; then
		echo $*
	fi
}

# Update base of the game
function update_game() {
	# cd to where the game is
	cd $game_path
	vecho "Updating game"

	# pull first just in case non of this nonsense is needed
	git pull $base_repo
	if [[ $? != 0 ]]; then
		echo "Finished! No stashing needed, repos don't conflict."
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
}

# run it and check for an error
game_update=`update_game`
if [[ $game_update != 0 ]]; then # there was an error
	echo $game_update
fi
vecho "Base updated successfully!"

function update_mods() {
	vecho "Updating mods"
	
	# iterate over all mods
	for dir in $MODS/* ; do
    	dir=${dir%*/}
    	cd ${dir#*/}
    	vecho "Checking ${dir##*/} {${dir#*/}}"
    	# check the existance of a .git directory
    	git pull
    	local errorcount=0
    	local status=$?
    	if [[ $status != 0 ]]; then
    		vecho "Initial pull failed for ${dir##*/} error code is $status"
    		git stash
    		status=$?
    		if [[ $status != 0 ]]; then
    			echo "Failed to stash changes to ${dir##*/}"
    			errorcount=$errorcount+1000000
    		fi
    		git pull
    		status=$?
    		if [[ $status != 0 ]]; then
    			echo "Second pull failed." ##, restoring stasshed changes."
    			errorcount=$errorcount+1
    		fi
    	elif [[ $status == 128 ]]; then
    		vecho "Skipping update for ${dir##*/} not a git repository."
    	else
    		vecho "${dir##*/} pulled successfully!"
    	fi
    	return 0
	done
}

# run it and check for an error
mods_update=`update_mods`
if [[ $mods_update != 0 ]]; then # there was an error
	echo $mods_update
fi
vecho "Base updated successfully!"
