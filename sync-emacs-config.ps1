# Temporary file to write Git output to
New-Variable -Name tempfile -Value "C:\Users\$env:UserName\AppData\Local\Temp\tempfile-$pid"

# Emacs default directory
New-Variable -Name emacs-home -Value "C:\Users\$env:UserName\AppData\Roaming"

# current working directory
New-Variable -Name current-directory -Value (Get-Item -Path '.\').FullName

# Main code: sync emacs configuration from Github
function sync-configuration()
{
    # cd into emacs config directory and pull changes from Github
    cd "C:\Users\$env:UserName\Git\custom-emacs-config"
    git pull > "$tempfile"

    # Store content of tempfile in a variable
    $tempfile_content = Get-Content "$tempfile"

    # If the content in the tempfile is
    # "Already up to date.", it means that the local
    # repository is up to date with the remote
    if($tempfile_content -eq "Already up to date.")
    {
	Write "Configuration is already up to date."
	exit
    }

    else
    {
	# Backup older config
	Copy-Item -Force "$emacs-home\.emacs" "$emacs-home\.emacs.bkp"
	Copy-Item -Force "$emacs-home\.config.org" ".\.config.org.bkp"

	# Copy new config
	Copy-Item -Force ".\.emacs" "$emacs-home\.emacs"
	Copy-Item -Force ".\.config.org" "$emacs-home\.config.org"

	Write "Configuration synced successfully."
	exit
    }
}

# Start synchronization
try
{
    sync-configuration
}

# Remove tempfile and restore previous working directory
finally
{
    Remove-Item -Force "$tempfile"
    cd "$current-directory"
}
