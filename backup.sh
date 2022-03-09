#!/bin/sh

source "$( dirname "${BASH_SOURCE[0]}" )/functions.sh"
source "$( dirname "${BASH_SOURCE[0]}" )/appConfig.sh"

##########################################################################################################################################################
# Global variables
##########################################################################################################################################################
DATE=`date +%Y%m%d%H%M%S`

##########################################################################################################################################################
# Function to backup the application configuration specified by the parameter.
#
# Arguments: $1 the application configuration to backup
##########################################################################################################################################################
function backup_app_config() {
    echo "*** Starting $1 Backup on $(date) ***" >&2
    DATE=`date +%Y%m%d%H%M%S`
    BACKUP_PATH=$( get_backup_path $1 )
    mkdir -p $BACKUP_PATH
    BACKUP_PREFIX=$( get_app_prefix $1 )
    BACKUP_FILE=$BACKUP_PATH/$BACKUP_PREFIX-$DATE.tar.gz
    get_files_to_backup $1
    get_files_to_exclude_from_backup $1
    /bin/tar -zcvf $BACKUP_FILE -T "$TMP_FILE_LIST" --exclude-from=$TMP_FILE_LIST_TO_EXCLUDE
    echo "*** ending $1 Backup on $(date) ***" >&2
}

##########################################################################################################################################################
# Main program
##########################################################################################################################################################
clear
check_arguments_for_backup $@
backup_app_config $1
