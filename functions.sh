#!/bin/sh

source "$( dirname "${BASH_SOURCE[0]}" )/appConfig.sh"

##########################################################################################################################################################
# Function to check the correct number of arguments provided for backing up an application configuration.
#
# Arguments: $@ the arguments provided by the main program
##########################################################################################################################################################
function check_arguments_for_backup() {
    if [[ $# -eq 0 ]]; then
        echo "ERROR: No arguments provided: please specify which application configuration to backup:" >&2
        print_app_configs && exit 1
    elif [[ $# -eq 1 ]]; then
        check_valid_app $1
    else
        echo "ERROR: Wrong number of arguments supplied. Only one argument allowed to specifiy which application configuration needs to be backed up:" >&2
        print_app_configs && exit 1
    fi
}

##########################################################################################################################################################
# Function to check if the correct application configuration parameter for the application to backup or restore has been provided:
#
# Arguments: $1 the application configuration to backup or restore
##########################################################################################################################################################
function check_valid_app() {
    (for e in "${APPS[@]}"; do [[ "$e" == "$1" ]] && exit 0; done) && VALID_APP=true || VALID_APP=false
    if [[ "$VALID_APP" != "true" ]]; then
        echo "ERROR: No valid application configuration selected for backup or restore. Please select a valid application configuration:" >&2
        print_app_configs && exit 1
    fi
}

##########################################################################################################################################################
# Function to print out the possible application configuration paramters in case of wrongly provided parameters.
#
# Arguments: $1 the application configuration to backup or restore
##########################################################################################################################################################
function print_app_configs() {
    printf "  %s\n"  "${APPS[@]}" >&2
}

##########################################################################################################################################################
# Function to create a temporary file containing the files that need to be backed up based on the given parameter.
#
# Arguments: $@ an array containing the files to be backed up
##########################################################################################################################################################
function create_files_to_backup() {
    if [[ ! -e "$TMP_FILE_LIST" ]] ; then
        touch "$TMP_FILE_LIST"
    else
        >| "$TMP_FILE_LIST"
    fi    

    FILES_TO_BACKUP=("$@")
    for FILE in "${FILES_TO_BACKUP[@]}"; do
        echo "$FILE" >> "$TMP_FILE_LIST"
    done
    echo "Files To backup"
    more $TMP_FILE_LIST
}

##########################################################################################################################################################
# Function to create a temporary file containing the files that should be excluded from the backup based on the given parameter.
#
# Arguments: $@ an array containing the files that should be excluded from the backup
##########################################################################################################################################################
function create_files_to_exclude_from_backup() {
    if [[ ! -e "$TMP_FILE_LIST_TO_EXCLUDE" ]] ; then
        touch "$TMP_FILE_LIST_TO_EXCLUDE"
    else
        >| "$TMP_FILE_LIST_TO_EXCLUDE"
    fi    

    FILES_TO_EXCLUDE_FROM_BACKUP=("$@")
    for FILE in "${FILES_TO_EXCLUDE_FROM_BACKUP[@]}"; do
        echo "$FILE" >> "$TMP_FILE_LIST_TO_EXCLUDE"
    done
    echo "Files To exclude"
    more $TMP_FILE_LIST_TO_EXCLUDE
}

##########################################################################################################################################################
# Function to check the correct number of arguments provided for restoring an application configuration.
#
# Arguments: $@ the arguments provided by the main program
##########################################################################################################################################################
function get_filename_to_use_for_restore() {
    local BACKUP_PATH=$( get_backup_path $1 )
    local BACKUP_PREFIX=$( get_app_prefix $1 )
    local FILENAME_TO_USE_FOR_RESTORE=""
    if [[ $# -eq 0 ]]; then
        print_restore_usage
    elif [[ $# -eq 1 ]]; then
        check_valid_app $1
        echo "No datetime arguments provided: using latest backup file for restore" >&2
        cd $BACKUP_PATH
        local FILENAME_TO_USE_FOR_RESTORE=$BACKUP_PATH/$(ls -t | head -n1)
        cd $CURRENT_DIR
    elif [[ $# -eq 2 ]]; then
        check_valid_app $1
        DATE_STRING=$( get_date_as_string $2 )
        if [[ "$2" == "$DATE_STRING" ]]; then
            local FILENAME_TO_USE_FOR_RESTORE=$BACKUP_PATH/$BACKUP_PREFIX-$DATE_STRING.tar.gz
        fi
    else
        print_restore_usage
    fi
    echo $FILENAME_TO_USE_FOR_RESTORE
}

##########################################################################################################################################################
# Function to print out restore usage.
##########################################################################################################################################################
function print_restore_usage() {
    echo "ERROR: No arguments provided." >&2
    echo "The first argument should be a valid application configuration id:" >&2
    print_app_configs
    echo "The second argument can be a datetime string in the format of YYYYMMDDHHMMSS." >&2
    echo "If no datetime string is provided, the latest backup file will be used for restore." >&2
    exit 1
}

##########################################################################################################################################################
# Function to get the provided date as a string.
#
# Arguments: $1 the date provided
##########################################################################################################################################################
function get_date_as_string() {
    echo "Check if provided date/time $1 string is valid" >&2
    DATE_OF_BACKUP_FILE=$(gawk -v t=$1 'BEGIN {gsub(/../, "& ", t); sub(/ /,"",t); print mktime(t)}')
    if [[ $DATE_OF_BACKUP_FILE -eq -1 ]]; then
        echo "ERROR: Invalid date/time string provided as input argument" >&2 && exit 1
    fi
    DATE_STRING=$(date +%Y%m%d%H%M%S -d @$DATE_OF_BACKUP_FILE)
    echo $DATE_STRING
}
