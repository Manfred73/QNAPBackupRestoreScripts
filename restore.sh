#!/bin/sh

source "$( dirname "${BASH_SOURCE[0]}" )/functions.sh"
source "$( dirname "${BASH_SOURCE[0]}" )/appConfig.sh"

##########################################################################################################################################################
# Function to restore the application configuration specified by the parameters provided.
#
# Arguments: $@ the arugments for restoring an application configuration:
#   - first argument should be the application configuration id
#   - second argument can be a datetime string in the format of YYYYMMDDHHMMSS
##########################################################################################################################################################
function restore() {

    # TODO: if app to restore is Radarr, remove everything from RADARR_PATH first (is this still neccessary, or was this only for Synology?)
    # Remove everything from RADARR_PATH first
    # cd $RADARR_PATH
    # rm -Rf *

    echo "*** Starting restore $1 on $(date) ***" >&2
    FILENAME_TO_USE_FOR_RESTORE=$( get_filename_to_use_for_restore $@ )
    if [[ ! -z "${FILENAME_TO_USE_FOR_RESTORE/ //}" ]]; then
        echo "FILENAME RESTORE: $FILENAME_TO_USE_FOR_RESTORE" >&2
        /bin/tar -zxvf $FILENAME_TO_USE_FOR_RESTORE -C /
    fi
    echo "*** ending restore $1 Full Backup on $(date) ***" >&2

    # TODO: if app to restore is Radarr, set permissions for Radarr (is this still neccessary, or was this only for Synology?)
    # Update permissions
    # cd $RADARR_APPDIR_PATH
    # chown -R radarr:users *
    # chmod -R 0644 *
}

##########################################################################################################################################################
# Main program
##########################################################################################################################################################
clear
restore $@
