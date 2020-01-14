#!/usr/bin/env bash

# Temporary file to write Git output to.
tempfile="/tmp/sync-emacs-output-$$"

# Remove temporary file when script exits
trap remove_tempfile EXIT

# Function to remove temporary file
function remove_tempfile()
{
	rm -f $tempfile > /dev/null 2>&1
}

# Main code: sync emacs configuration from Github
function sync_configuration()
{
    # Notify user that script has started
    notify-send "Syncing Emacs configuration" "Syncing..."

    cd ~/Git/custom-emacs-config
    git pull | tee $tempfile

    # Count number of lines of output produced by git pull
    line_count=`wc -l < $tempfile | awk '{print $1}'`

    # If git pull produced only 1 line of ouput, it means
    # that the local repository is up to date with the remote
    if [ $line_count == "1" ]
    then
	# Send user a notification
	notify-send "Sync Emacs configuration" "Already up to date."
	exit 0
    else
	# Backup older config
	cp ~/.emacs ~/.emacs.bkp
	cp ~/.config.org ~/.config.org.bkp

	# Copy new config ~/
	cp .emacs ~/
	cp .config.org ~/

	# Send user a notification
	notify-send "Sync Emacs configuration" "Syncing completed."
	exit 0
    fi
}

# Give user a warning if script is run as root
if [ $UID -eq 0 ]
then
    echo "WARNING. Running script as root..."
    sync_configuration
else
    sync_configuration
fi
